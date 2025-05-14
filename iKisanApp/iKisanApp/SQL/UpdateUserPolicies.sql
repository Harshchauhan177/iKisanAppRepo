-- Drop existing restrictive policy
DROP POLICY IF EXISTS "Users can view their own data" ON "public"."users";

-- Create new policy allowing users to view all users
CREATE POLICY "Users can view all users" ON "public"."users"
  FOR SELECT USING (true);

-- Keep the update policy restricted to own data
DROP POLICY IF EXISTS "Users can update their own data" ON "public"."users";
CREATE POLICY "Users can update their own data" ON "public"."users"
  FOR UPDATE USING (auth.uid()::text = "userID"::text);

-- Ensure RLS is enabled
ALTER TABLE "public"."users" FORCE ROW LEVEL SECURITY; 