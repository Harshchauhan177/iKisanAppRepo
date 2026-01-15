-- ================================================================
-- CRON JOB: Kick Non-Paying Participants
-- Runs every 10 minutes to enforce payment deadlines
-- ================================================================

-- ----------------------------------------------------------------
-- SETUP: Enable pg_cron Extension (Run as Superuser)
-- ----------------------------------------------------------------
-- Note: This requires superuser privileges and may need to be run 
-- via Supabase Dashboard or by database administrator

-- Enable pg_cron extension (if not already enabled)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ----------------------------------------------------------------
-- CRON JOB: Schedule Kick Function
-- ----------------------------------------------------------------

-- Remove existing cron job if it exists (wrapped to handle first-time setup)
DO $$ 
BEGIN
    PERFORM cron.unschedule('kick_non_paying_participants_job');
    RAISE NOTICE 'Unscheduled existing job';
EXCEPTION 
    WHEN OTHERS THEN
        RAISE NOTICE 'Job does not exist yet, skipping unschedule';
END $$;

-- Schedule function to run every 10 minutes
-- Cron expression: */10 * * * * = every 10 minutes
SELECT cron.schedule(
    'kick_non_paying_participants_job',  -- Job name
    '*/10 * * * *',                      -- Run every 10 minutes
    $$SELECT kick_non_paying_participants();$$
);

-- ----------------------------------------------------------------
-- VERIFY CRON JOB
-- ----------------------------------------------------------------

-- View all scheduled cron jobs
SELECT * FROM cron.job WHERE jobname = 'kick_non_paying_participants_job';

-- View cron job execution history (last 10 runs)
SELECT * FROM cron.job_run_details 
WHERE jobid = (
    SELECT jobid FROM cron.job 
    WHERE jobname = 'kick_non_paying_participants_job'
)
ORDER BY start_time DESC 
LIMIT 10;

-- ----------------------------------------------------------------
-- ALTERNATIVE: Supabase Edge Function Approach
-- ----------------------------------------------------------------
-- If pg_cron is not available, use Supabase Edge Functions with:
-- 1. Create an Edge Function that calls kick_non_paying_participants()
-- 2. Use GitHub Actions or external cron service to trigger it
-- 3. Secure with a secret token

-- Example Edge Function (TypeScript):
/*
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  try {
    // Verify secret token
    const authHeader = req.headers.get('Authorization')
    if (authHeader !== `Bearer ${Deno.env.get('CRON_SECRET')}`) {
      return new Response('Unauthorized', { status: 401 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Call the kick function
    const { data, error } = await supabase.rpc('kick_non_paying_participants')

    if (error) throw error

    return new Response(
      JSON.stringify({ 
        success: true, 
        result: data 
      }),
      { headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})
*/

-- ----------------------------------------------------------------
-- MONITORING QUERIES
-- ----------------------------------------------------------------

-- Check groups currently in collecting_payment state
SELECT 
    r.id,
    r.status,
    r.payment_deadline,
    r.payment_deadline - NOW() as time_remaining,
    COUNT(rp.id) as total_participants,
    COUNT(CASE WHEN rp.payment_status = 'paid' THEN 1 END) as paid_count,
    COUNT(CASE WHEN rp.payment_status = 'pending' THEN 1 END) as pending_count
FROM public.requests r
LEFT JOIN public.request_participants rp ON rp."requestId" = r.id
WHERE r.status = 'collecting_payment'
GROUP BY r.id, r.status, r.payment_deadline
ORDER BY r.payment_deadline ASC;

-- View recent kick events
SELECT 
    gpal.*,
    u.name as kicked_user_name
FROM public.group_payment_audit_log gpal
LEFT JOIN public.request_participants rp ON rp.id = gpal.participant_id
LEFT JOIN public.users u ON u."userID" = rp."userId"
WHERE gpal.event_type = 'user_kicked'
ORDER BY gpal.created_at DESC
LIMIT 20;

-- Summary of cron executions
SELECT 
    event_data->>'execution_time' as execution_time,
    event_data->>'kicked_count' as kicked_count,
    event_data->>'affected_groups' as affected_groups
FROM public.group_payment_audit_log
WHERE event_type = 'cron_execution'
ORDER BY created_at DESC
LIMIT 10;

-- ----------------------------------------------------------------
-- MANUAL EXECUTION (For Testing)
-- ----------------------------------------------------------------

-- Test the kick function manually
SELECT * FROM kick_non_paying_participants();

-- Simulate expired deadline for testing
-- UPDATE public.requests 
-- SET payment_deadline = NOW() - INTERVAL '1 minute'
-- WHERE id = '<test-group-id>' AND status = 'collecting_payment';

-- Then run kick function
-- SELECT * FROM kick_non_paying_participants();
