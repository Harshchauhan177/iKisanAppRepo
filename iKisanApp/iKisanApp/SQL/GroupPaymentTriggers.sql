-- ================================================================
-- BACKEND LOGIC: TRIGGERS AND FUNCTIONS
-- Group Payment Workflow Automation
-- ================================================================

-- ----------------------------------------------------------------
-- FUNCTION 1: Start Payment Collection Timer
-- Triggered when provider accepts group (status → 'collecting_payment')
-- ----------------------------------------------------------------
CREATE OR REPLACE FUNCTION start_payment_collection_timer()
RETURNS TRIGGER AS $$
BEGIN
    -- Only execute if status changed TO 'collecting_payment'
    IF NEW.status = 'collecting_payment' AND (OLD.status IS NULL OR OLD.status != 'collecting_payment') THEN
        -- Set payment deadline to 4 hours from now
        NEW.payment_deadline := NOW() + INTERVAL '4 hours';
        
        -- Log the event
        INSERT INTO public.group_payment_audit_log (
            request_id,
            event_type,
            event_data,
            created_at
        ) VALUES (
            NEW.id,
            'timer_started',
            jsonb_build_object(
                'deadline', NEW.payment_deadline,
                'duration_hours', 4,
                'triggered_at', NOW()
            ),
            NOW()
        );
        
        RAISE NOTICE 'Payment timer started for group %. Deadline: %', NEW.id, NEW.payment_deadline;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on requests table
DROP TRIGGER IF EXISTS trigger_start_payment_timer ON public.requests;
CREATE TRIGGER trigger_start_payment_timer
    BEFORE UPDATE ON public.requests
    FOR EACH ROW
    EXECUTE FUNCTION start_payment_collection_timer();

COMMENT ON FUNCTION start_payment_collection_timer() IS 
'Automatically sets payment_deadline when group status changes to collecting_payment';

-- ----------------------------------------------------------------
-- FUNCTION 2: Check and Activate Group When All Paid
-- Triggered when participant payment_status changes to 'paid'
-- ----------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_group_full_payment()
RETURNS TRIGGER AS $$
DECLARE
    v_request_id UUID;
    v_total_participants INTEGER;
    v_paid_participants INTEGER;
    v_current_status TEXT;
BEGIN
    v_request_id := NEW."requestId";
    
    -- Only proceed if payment status changed to 'paid'
    IF NEW.payment_status = 'paid' AND (OLD.payment_status IS NULL OR OLD.payment_status != 'paid') THEN
        
        -- Get current request status
        SELECT status INTO v_current_status
        FROM public.requests
        WHERE id = v_request_id;
        
        -- Only proceed if group is in 'collecting_payment' status
        IF v_current_status = 'collecting_payment' THEN
            
            -- Count total participants
            SELECT COUNT(*) INTO v_total_participants
            FROM public.request_participants
            WHERE "requestId" = v_request_id;
            
            -- Count paid participants
            SELECT COUNT(*) INTO v_paid_participants
            FROM public.request_participants
            WHERE "requestId" = v_request_id
            AND payment_status = 'paid';
            
            RAISE NOTICE 'Group % payment check: % paid out of % total', 
                v_request_id, v_paid_participants, v_total_participants;
            
            -- If all participants have paid, activate the group
            IF v_paid_participants = v_total_participants AND v_total_participants > 0 THEN
                UPDATE public.requests
                SET 
                    status = 'active',
                    payment_deadline = NULL, -- Clear deadline since payment is complete
                    updated_at = NOW()
                WHERE id = v_request_id;
                
                -- Log activation event
                INSERT INTO public.group_payment_audit_log (
                    request_id,
                    event_type,
                    event_data,
                    created_at
                ) VALUES (
                    v_request_id,
                    'group_activated',
                    jsonb_build_object(
                        'total_participants', v_total_participants,
                        'all_paid', true,
                        'activated_at', NOW()
                    ),
                    NOW()
                );
                
                RAISE NOTICE '✅ Group % activated - all participants paid', v_request_id;
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on request_participants table
DROP TRIGGER IF EXISTS trigger_check_full_payment ON public.request_participants;
CREATE TRIGGER trigger_check_full_payment
    AFTER UPDATE ON public.request_participants
    FOR EACH ROW
    EXECUTE FUNCTION check_group_full_payment();

COMMENT ON FUNCTION check_group_full_payment() IS 
'Checks if all participants have paid and activates the group accordingly';

-- ----------------------------------------------------------------
-- FUNCTION 3: Kick Non-Paying Participants (Called by Cron)
-- Removes participants who haven't paid by deadline
-- ----------------------------------------------------------------
CREATE OR REPLACE FUNCTION kick_non_paying_participants()
RETURNS TABLE (
    kicked_count INTEGER,
    affected_groups UUID[]
) AS $$
DECLARE
    v_kicked_count INTEGER := 0;
    v_affected_groups UUID[] := ARRAY[]::UUID[];
    v_expired_request RECORD;
    v_kicked_participant RECORD;
    v_remaining_total_area DOUBLE PRECISION;
    v_target_area DOUBLE PRECISION;
BEGIN
    -- Find all groups with expired payment deadlines
    FOR v_expired_request IN
        SELECT id, area as target_area, status
        FROM public.requests
        WHERE status = 'collecting_payment'
        AND payment_deadline < NOW()
    LOOP
        RAISE NOTICE 'Processing expired group: %', v_expired_request.id;
        
        -- Find and kick non-paying participants
        FOR v_kicked_participant IN
            SELECT id, "userId", "requestId"
            FROM public.request_participants
            WHERE "requestId" = v_expired_request.id
            AND payment_status = 'pending'
        LOOP
            -- Soft delete: Update status to 'rejected' or 'kicked'
            UPDATE public.request_participants
            SET 
                status = 'rejected',
                updated_at = NOW()
            WHERE id = v_kicked_participant.id;
            
            -- Log kick event
            INSERT INTO public.group_payment_audit_log (
                request_id,
                participant_id,
                event_type,
                event_data,
                created_at
            ) VALUES (
                v_expired_request.id,
                v_kicked_participant.id,
                'user_kicked',
                jsonb_build_object(
                    'userId', v_kicked_participant."userId",
                    'reason', 'payment_timeout',
                    'deadline_missed', v_expired_request.id
                ),
                NOW()
            );
            
            v_kicked_count := v_kicked_count + 1;
            RAISE NOTICE '❌ Kicked participant % from group %', 
                v_kicked_participant."userId", v_expired_request.id;
        END LOOP;
        
        -- Calculate remaining total area (only active participants)
        SELECT COALESCE(SUM(rp.area), 0) INTO v_remaining_total_area
        FROM public.request_participants rp
        WHERE rp."requestId" = v_expired_request.id
        AND rp.status NOT IN ('rejected');
        
        -- Get target area
        v_target_area := v_expired_request.target_area;
        
        RAISE NOTICE 'Remaining area: %, Target area: %', 
            v_remaining_total_area, v_target_area;
        
        -- If remaining area < target area, reopen the group
        IF v_remaining_total_area < v_target_area THEN
            UPDATE public.requests
            SET 
                status = 'pending', -- Reopen for new participants
                payment_deadline = NULL,
                updated_at = NOW()
            WHERE id = v_expired_request.id;
            
            -- Log reopening
            INSERT INTO public.group_payment_audit_log (
                request_id,
                event_type,
                event_data,
                created_at
            ) VALUES (
                v_expired_request.id,
                'group_reopened',
                jsonb_build_object(
                    'reason', 'insufficient_area_after_kicks',
                    'remaining_area', v_remaining_total_area,
                    'target_area', v_target_area
                ),
                NOW()
            );
            
            RAISE NOTICE '🔄 Group % reopened due to insufficient area', v_expired_request.id;
        END IF;
        
        -- Track affected group
        v_affected_groups := array_append(v_affected_groups, v_expired_request.id);
    END LOOP;
    
    kicked_count := v_kicked_count;
    affected_groups := v_affected_groups;
    
    RETURN QUERY SELECT v_kicked_count, v_affected_groups;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION kick_non_paying_participants() IS 
'Removes participants who missed payment deadline and reopens groups if needed. Called by cron job.';

-- ----------------------------------------------------------------
-- FUNCTION 4: Helper - Get Group Payment Summary
-- Returns payment status for a specific group
-- ----------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_group_payment_summary(p_request_id UUID)
RETURNS TABLE (
    request_id UUID,
    group_status TEXT,
    payment_deadline TIMESTAMPTZ,
    total_participants INTEGER,
    paid_participants INTEGER,
    pending_participants INTEGER,
    total_amount_collected NUMERIC,
    time_remaining INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id as request_id,
        r.status::TEXT as group_status,
        r.payment_deadline,
        COUNT(rp.id)::INTEGER as total_participants,
        COUNT(CASE WHEN rp.payment_status = 'paid' THEN 1 END)::INTEGER as paid_participants,
        COUNT(CASE WHEN rp.payment_status = 'pending' THEN 1 END)::INTEGER as pending_participants,
        COALESCE(SUM(CASE WHEN rp.payment_status = 'paid' THEN rp.payment_amount ELSE 0 END), 0) as total_amount_collected,
        CASE 
            WHEN r.payment_deadline IS NOT NULL THEN r.payment_deadline - NOW()
            ELSE NULL
        END as time_remaining
    FROM public.requests r
    LEFT JOIN public.request_participants rp ON rp."requestId" = r.id
    WHERE r.id = p_request_id
    GROUP BY r.id, r.status, r.payment_deadline;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_group_payment_summary(UUID) IS 
'Returns a summary of payment status for a specific group request';

-- ----------------------------------------------------------------
-- FUNCTION 5: RPC Endpoint - Record Payment Success
-- Called from iOS app after Razorpay payment succeeds
-- ----------------------------------------------------------------
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
BEGIN
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
            'user_id', p_user_id
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
'Securely records a successful payment from iOS app. Called after Razorpay verification.';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION record_participant_payment(UUID, UUID, TEXT, NUMERIC) TO authenticated;

-- ----------------------------------------------------------------
-- TEST QUERIES
-- ----------------------------------------------------------------

-- Test 1: Simulate provider acceptance
-- UPDATE public.requests SET status = 'collecting_payment' WHERE id = '<your-group-id>';

-- Test 2: Simulate participant payment
-- SELECT record_participant_payment(
--     '<request-id>'::UUID,
--     '<user-id>'::UUID,
--     'pay_test123',
--     100.00
-- );

-- Test 3: Check group payment summary
-- SELECT * FROM get_group_payment_summary('<request-id>'::UUID);

-- Test 4: Run kick function manually (normally done by cron)
-- SELECT * FROM kick_non_paying_participants();

-- Test 5: View audit log
-- SELECT * FROM public.group_payment_audit_log 
-- WHERE request_id = '<request-id>'
-- ORDER BY created_at DESC;
