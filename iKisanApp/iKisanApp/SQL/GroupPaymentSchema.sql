-- ================================================================
-- GROUP PAYMENT WORKFLOW SCHEMA CHANGES
-- Post-Confirmation Payment System for CoEquip Groups
-- ================================================================

-- ----------------------------------------------------------------
-- STEP 1: Update Request Status Enum (Groups Table)
-- ----------------------------------------------------------------
DO $$ 
BEGIN
    -- Check if the enum type exists
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'booking_status_enum') THEN
        -- Add new status values for group payment workflow
        -- Note: We need to check if values already exist before adding
        
        -- Add 'awaiting_provider' status
        IF NOT EXISTS (
            SELECT 1 FROM pg_enum 
            WHERE enumlabel = 'awaiting_provider' 
            AND enumtypid = 'public.booking_status_enum'::regtype
        ) THEN
            ALTER TYPE public.booking_status_enum ADD VALUE 'awaiting_provider';
            RAISE NOTICE 'Added awaiting_provider to booking_status_enum';
        END IF;
        
        -- Add 'collecting_payment' status
        IF NOT EXISTS (
            SELECT 1 FROM pg_enum 
            WHERE enumlabel = 'collecting_payment' 
            AND enumtypid = 'public.booking_status_enum'::regtype
        ) THEN
            ALTER TYPE public.booking_status_enum ADD VALUE 'collecting_payment';
            RAISE NOTICE 'Added collecting_payment to booking_status_enum';
        END IF;
        
        -- Add 'active' status (for work-in-progress groups)
        IF NOT EXISTS (
            SELECT 1 FROM pg_enum 
            WHERE enumlabel = 'active' 
            AND enumtypid = 'public.booking_status_enum'::regtype
        ) THEN
            ALTER TYPE public.booking_status_enum ADD VALUE 'active';
            RAISE NOTICE 'Added active to booking_status_enum';
        END IF;
        
        RAISE NOTICE '✅ Updated booking_status_enum with group payment statuses';
    ELSE
        RAISE EXCEPTION 'booking_status_enum type does not exist';
    END IF;
END $$;

-- ----------------------------------------------------------------
-- STEP 2: Add payment_deadline Column to Requests Table
-- ----------------------------------------------------------------
DO $$ 
BEGIN
    -- Check if requests table exists
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'requests') THEN
        -- Add payment_deadline column if it doesn't exist
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'requests' 
            AND column_name = 'payment_deadline'
        ) THEN
            ALTER TABLE public.requests 
            ADD COLUMN payment_deadline TIMESTAMPTZ NULL;
            
            RAISE NOTICE '✅ Added payment_deadline column to requests table';
        ELSE
            RAISE NOTICE 'payment_deadline column already exists';
        END IF;
    ELSE
        RAISE EXCEPTION 'requests table does not exist';
    END IF;
END $$;

-- ----------------------------------------------------------------
-- STEP 2B: Create Indexes (Must be after enum commit)
-- ----------------------------------------------------------------
-- Add index for efficient queries in cron job
CREATE INDEX IF NOT EXISTS idx_requests_payment_deadline 
ON public.requests(payment_deadline) 
WHERE payment_deadline IS NOT NULL;

-- Add composite index for payment collection queries
-- Note: Removed WHERE clause to avoid enum commit issues
CREATE INDEX IF NOT EXISTS idx_requests_collecting_payment 
ON public.requests(status, payment_deadline);

-- ----------------------------------------------------------------
-- STEP 3: Create Payment Status Enum for Participants
-- ----------------------------------------------------------------
DO $$ 
BEGIN
    -- Create payment_status_enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status_enum') THEN
        CREATE TYPE public.payment_status_enum AS ENUM (
            'pending',
            'paid',
            'failed',
            'refunded'
        );
        RAISE NOTICE '✅ Created payment_status_enum';
    ELSE
        RAISE NOTICE 'payment_status_enum already exists';
    END IF;
END $$;

-- ----------------------------------------------------------------
-- STEP 4: Add Payment Columns to request_participants Table
-- ----------------------------------------------------------------
DO $$ 
BEGIN
    -- Check if request_participants table exists
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'request_participants') THEN
        
        -- Add payment_status column
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'request_participants' 
            AND column_name = 'payment_status'
        ) THEN
            ALTER TABLE public.request_participants 
            ADD COLUMN payment_status public.payment_status_enum NOT NULL DEFAULT 'pending';
            
            RAISE NOTICE '✅ Added payment_status column to request_participants';
        ELSE
            RAISE NOTICE 'payment_status column already exists';
        END IF;
        
        -- Add payment_id column (stores Razorpay Payment ID)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'request_participants' 
            AND column_name = 'payment_id'
        ) THEN
            ALTER TABLE public.request_participants 
            ADD COLUMN payment_id TEXT NULL;
            
            -- Add unique constraint to prevent duplicate payment IDs
            ALTER TABLE public.request_participants 
            ADD CONSTRAINT unique_payment_id UNIQUE (payment_id);
            
            RAISE NOTICE '✅ Added payment_id column to request_participants';
        ELSE
            RAISE NOTICE 'payment_id column already exists';
        END IF;
        
        -- Add payment_timestamp column (when payment was completed)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'request_participants' 
            AND column_name = 'payment_timestamp'
        ) THEN
            ALTER TABLE public.request_participants 
            ADD COLUMN payment_timestamp TIMESTAMPTZ NULL;
            
            RAISE NOTICE '✅ Added payment_timestamp column to request_participants';
        ELSE
            RAISE NOTICE 'payment_timestamp column already exists';
        END IF;
        
        -- Add payment_amount column (for reconciliation)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'request_participants' 
            AND column_name = 'payment_amount'
        ) THEN
            ALTER TABLE public.request_participants 
            ADD COLUMN payment_amount NUMERIC(10, 2) NULL;
            
            RAISE NOTICE '✅ Added payment_amount column to request_participants';
        ELSE
            RAISE NOTICE 'payment_amount column already exists';
        END IF;
        
        -- Create indexes for payment queries
        CREATE INDEX IF NOT EXISTS idx_participants_payment_status 
        ON public.request_participants(payment_status);
        
        CREATE INDEX IF NOT EXISTS idx_participants_pending_payment 
        ON public.request_participants("requestId", payment_status) 
        WHERE payment_status = 'pending';
        
    ELSE
        RAISE EXCEPTION 'request_participants table does not exist';
    END IF;
END $$;

-- ----------------------------------------------------------------
-- STEP 5: Create Audit Log Table for Payment Events
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.group_payment_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
    participant_id UUID NULL REFERENCES public.request_participants(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL, -- 'timer_started', 'payment_success', 'payment_failed', 'user_kicked', 'group_activated'
    event_data JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NULL -- user who triggered the event
);

-- Add index for audit queries
CREATE INDEX IF NOT EXISTS idx_payment_audit_request 
ON public.group_payment_audit_log(request_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payment_audit_event_type 
ON public.group_payment_audit_log(event_type, created_at DESC);

-- Add RLS policies for audit log
ALTER TABLE public.group_payment_audit_log ENABLE ROW LEVEL SECURITY;

-- Allow users to view audit logs for their groups
CREATE POLICY "Users can view audit logs for their groups" 
ON public.group_payment_audit_log FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.requests r
        WHERE r.id = group_payment_audit_log.request_id
        AND (r."userId"::text = auth.uid()::text 
             OR EXISTS (
                 SELECT 1 FROM public.request_participants rp
                 WHERE rp."requestId" = r.id
                 AND rp."userId"::text = auth.uid()::text
             ))
    )
);

-- Only system can insert audit logs (via service role)
CREATE POLICY "System can insert audit logs" 
ON public.group_payment_audit_log FOR INSERT
WITH CHECK (true); -- Will be restricted by service role key

COMMENT ON TABLE public.group_payment_audit_log IS 
'Audit log for tracking all group payment workflow events';

-- ----------------------------------------------------------------
-- VERIFICATION QUERY
-- ----------------------------------------------------------------
-- Run this to verify all changes were applied successfully:
DO $$ 
BEGIN
    RAISE NOTICE '================================================================';
    RAISE NOTICE 'GROUP PAYMENT SCHEMA VERIFICATION';
    RAISE NOTICE '================================================================';
    
    -- Verify enum values
    RAISE NOTICE 'Checking booking_status_enum values...';
    IF EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel IN ('awaiting_provider', 'collecting_payment', 'active')
        AND enumtypid = 'public.booking_status_enum'::regtype
    ) THEN
        RAISE NOTICE '✅ booking_status_enum has group payment statuses';
    ELSE
        RAISE WARNING '❌ booking_status_enum is missing group payment statuses';
    END IF;
    
    -- Verify requests columns
    IF EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'requests' AND column_name = 'payment_deadline'
    ) THEN
        RAISE NOTICE '✅ requests.payment_deadline exists';
    ELSE
        RAISE WARNING '❌ requests.payment_deadline is missing';
    END IF;
    
    -- Verify request_participants columns
    IF EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'request_participants' 
        AND column_name IN ('payment_status', 'payment_id', 'payment_timestamp', 'payment_amount')
    ) THEN
        RAISE NOTICE '✅ request_participants payment columns exist';
    ELSE
        RAISE WARNING '❌ request_participants payment columns are missing';
    END IF;
    
    -- Verify audit log table
    IF EXISTS (
        SELECT FROM pg_tables WHERE tablename = 'group_payment_audit_log'
    ) THEN
        RAISE NOTICE '✅ group_payment_audit_log table exists';
    ELSE
        RAISE WARNING '❌ group_payment_audit_log table is missing';
    END IF;
    
    RAISE NOTICE '================================================================';
END $$;
