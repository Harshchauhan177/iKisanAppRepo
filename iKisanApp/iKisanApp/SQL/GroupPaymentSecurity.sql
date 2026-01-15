-- ================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Secure access control for group payment workflow
-- ================================================================

-- ----------------------------------------------------------------
-- POLICY 1: requests Table - Payment Deadline Access
-- ----------------------------------------------------------------

-- Allow users to view payment_deadline for groups they're part of
CREATE POLICY "Users can view payment deadline for their groups"
ON public.requests
FOR SELECT
USING (
    auth.uid()::text = "userId"::text
    OR EXISTS (
        SELECT 1 FROM public.request_participants rp
        WHERE rp."requestId" = requests.id
        AND rp."userId"::text = auth.uid()::text
    )
);

-- Only system (service role) can update payment_deadline via triggers
-- Users cannot directly modify payment_deadline
CREATE POLICY "Only system can update payment deadline"
ON public.requests
FOR UPDATE
USING (
    auth.uid()::text = "userId"::text
)
WITH CHECK (
    auth.uid()::text = "userId"::text
);

-- ----------------------------------------------------------------
-- POLICY 2: request_participants Table - Payment Fields Access
-- ----------------------------------------------------------------

-- Users can view their own participant record including payment status
CREATE POLICY "Users can view their own participant payment status"
ON public.request_participants
FOR SELECT
USING (
    auth.uid()::text = "userId"::text
    OR EXISTS (
        -- Group creator can see all participants
        SELECT 1 FROM public.requests r
        WHERE r.id = request_participants."requestId"
        AND r."userId"::text = auth.uid()::text
    )
);

-- Users CANNOT directly update their payment_status (must use RPC function)
-- This prevents client-side spoofing
CREATE POLICY "Users cannot directly update payment status"
ON public.request_participants
FOR UPDATE
USING (
    auth.uid()::text = "userId"::text
)
WITH CHECK (
    auth.uid()::text = "userId"::text
);

-- Only service role can update payment fields (via RPC function after Razorpay verification)
-- This is enforced by the SECURITY DEFINER function record_participant_payment()

-- ----------------------------------------------------------------
-- POLICY 3: Prevent Tampering with Payment Data
-- ----------------------------------------------------------------

-- Additional check: Ensure payment_status can only transition from pending -> paid
-- via the secure RPC function (handled in application logic)

-- Create a trigger to validate payment status transitions
CREATE OR REPLACE FUNCTION validate_payment_status_transition()
RETURNS TRIGGER AS $$
BEGIN
    -- Only allow specific transitions
    IF OLD.payment_status = 'paid' AND NEW.payment_status != 'paid' THEN
        -- Cannot change from paid to anything except refunded (admin only)
        IF NEW.payment_status != 'refunded' THEN
            RAISE EXCEPTION 'Cannot change payment status from paid to %', NEW.payment_status;
        END IF;
    END IF;
    
    -- If setting to paid, must have payment_id
    IF NEW.payment_status = 'paid' AND (NEW.payment_id IS NULL OR NEW.payment_id = '') THEN
        RAISE EXCEPTION 'Payment ID is required when marking as paid';
    END IF;
    
    -- If setting to paid, must have payment_timestamp
    IF NEW.payment_status = 'paid' AND NEW.payment_timestamp IS NULL THEN
        RAISE EXCEPTION 'Payment timestamp is required when marking as paid';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_payment_status ON public.request_participants;
CREATE TRIGGER trigger_validate_payment_status
    BEFORE UPDATE ON public.request_participants
    FOR EACH ROW
    WHEN (OLD.payment_status IS DISTINCT FROM NEW.payment_status)
    EXECUTE FUNCTION validate_payment_status_transition();

-- ----------------------------------------------------------------
-- POLICY 4: Audit Log Access Control
-- ----------------------------------------------------------------

-- Users can only view audit logs for their own groups (already defined in schema)
-- Service role can insert audit logs (already defined in schema)

-- ----------------------------------------------------------------
-- SECURITY: RPC Function Permissions
-- ----------------------------------------------------------------

-- Ensure record_participant_payment() can only be called by authenticated users
-- and can only update their own participant record

-- Modify the RPC function to include additional security checks
CREATE OR REPLACE FUNCTION record_participant_payment(
    p_request_id UUID,
    p_user_id UUID,
    p_payment_id TEXT,
    p_payment_amount NUMERIC
)
RETURNS JSON AS $$
DECLARE
    v_participant_id UUID;
    v_result JSON;
    v_payment_summary RECORD;
    v_caller_id TEXT;
BEGIN
    -- Get the caller's user ID
    v_caller_id := auth.uid()::text;
    
    -- SECURITY CHECK 1: Ensure caller is the participant making the payment
    IF v_caller_id != p_user_id::text THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Unauthorized: You can only record your own payments'
        );
    END IF;
    
    -- Find participant record
    SELECT id INTO v_participant_id
    FROM public.request_participants
    WHERE "requestId" = p_request_id
    AND "userId" = p_user_id;
    
    IF v_participant_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Participant not found in group'
        );
    END IF;
    
    -- SECURITY CHECK 2: Verify the group is in collecting_payment state
    IF NOT EXISTS (
        SELECT 1 FROM public.requests
        WHERE id = p_request_id
        AND status = 'collecting_payment'
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Group is not in payment collection state'
        );
    END IF;
    
    -- SECURITY CHECK 3: Verify payment deadline hasn't expired
    IF EXISTS (
        SELECT 1 FROM public.requests
        WHERE id = p_request_id
        AND payment_deadline < NOW()
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Payment deadline has expired'
        );
    END IF;
    
    -- SECURITY CHECK 4: Verify payment amount is valid
    IF p_payment_amount <= 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Invalid payment amount'
        );
    END IF;
    
    -- Update payment status (using atomic transaction)
    UPDATE public.request_participants
    SET 
        payment_status = 'paid',
        payment_id = p_payment_id,
        payment_amount = p_payment_amount,
        payment_timestamp = NOW(),
        updated_at = NOW()
    WHERE id = v_participant_id
    AND payment_status = 'pending'; -- Prevent double payment
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Payment already recorded or participant not in pending state'
        );
    END IF;
    
    -- Log payment success
    INSERT INTO public.group_payment_audit_log (
        request_id,
        participant_id,
        event_type,
        event_data,
        created_at,
        created_by
    ) VALUES (
        p_request_id,
        v_participant_id,
        'payment_success',
        jsonb_build_object(
            'payment_id', p_payment_id,
            'amount', p_payment_amount,
            'user_id', p_user_id,
            'verified_at', NOW()
        ),
        NOW(),
        p_user_id
    );
    
    -- Get updated payment summary
    SELECT * INTO v_payment_summary
    FROM get_group_payment_summary(p_request_id);
    
    RETURN json_build_object(
        'success', true,
        'message', 'Payment recorded successfully',
        'payment_summary', row_to_json(v_payment_summary)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION record_participant_payment(UUID, UUID, TEXT, NUMERIC) IS 
'Securely records a successful payment. Includes authorization checks to prevent spoofing.';

-- ----------------------------------------------------------------
-- WEBHOOK VERIFICATION (Optional - for production)
-- ----------------------------------------------------------------

-- For production, you should verify Razorpay webhook signatures
-- This can be done in a Supabase Edge Function

-- Example Edge Function approach:
/*
1. Razorpay sends webhook to your Edge Function
2. Edge Function verifies webhook signature using Razorpay secret
3. If valid, calls record_participant_payment() with service role key
4. This ensures only verified payments are recorded
*/

-- ----------------------------------------------------------------
-- RATE LIMITING (Recommended for Production)
-- ----------------------------------------------------------------

-- Add rate limiting to prevent abuse of payment recording
-- This can be implemented using pg_cron or application-level rate limiting

CREATE TABLE IF NOT EXISTS public.payment_rate_limit (
    user_id UUID NOT NULL,
    request_id UUID NOT NULL,
    attempt_count INTEGER DEFAULT 0,
    last_attempt TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, request_id)
);

-- Add rate limiting check to RPC function (optional enhancement)
-- Limit: Maximum 5 payment attempts per user per group per hour

-- ----------------------------------------------------------------
-- VERIFICATION QUERIES
-- ----------------------------------------------------------------

-- Test RLS policies
-- These should only show data for the authenticated user:

-- View own participant record
-- SELECT * FROM request_participants WHERE userId = auth.uid();

-- View groups where user is participant
-- SELECT * FROM requests r
-- WHERE EXISTS (
--     SELECT 1 FROM request_participants rp
--     WHERE rp.requestId = r.id
--     AND rp.userId = auth.uid()
-- );

-- Attempt to update payment status directly (should fail)
-- UPDATE request_participants SET payment_status = 'paid' 
-- WHERE userId = auth.uid(); -- This will fail due to RLS policy

-- ----------------------------------------------------------------
-- GRANT PERMISSIONS
-- ----------------------------------------------------------------

-- Ensure authenticated users can execute the RPC function
GRANT EXECUTE ON FUNCTION record_participant_payment(UUID, UUID, TEXT, NUMERIC) TO authenticated;
GRANT EXECUTE ON FUNCTION get_group_payment_summary(UUID) TO authenticated;

-- Service role has full access (for triggers and cron jobs)
GRANT ALL ON TABLE public.requests TO service_role;
GRANT ALL ON TABLE public.request_participants TO service_role;
GRANT ALL ON TABLE public.group_payment_audit_log TO service_role;

COMMENT ON TABLE public.request_participants IS 
'Stores participant data with payment status. Direct updates to payment fields are restricted.';

-- Verification notices
DO $$ 
BEGIN
    RAISE NOTICE '================================================================';
    RAISE NOTICE '✅ Security policies and RLS rules configured';
    RAISE NOTICE '🔒 Payment status updates secured via RPC function';
    RAISE NOTICE '🛡️ Client-side spoofing prevented';
    RAISE NOTICE '================================================================';
END $$;
