-- Update users table to include email field
ALTER TABLE users 
ADD COLUMN email TEXT UNIQUE NOT NULL DEFAULT '';

-- Create trigger to handle auth.users synchronization with our application users
CREATE OR REPLACE FUNCTION public.handle_auth_user_created()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (
    "userID",
    email,
    name,
    phone,
    latitude,
    longitude,
    address,
    "fieldArea"
  ) VALUES (
    uuid(NEW.id),         -- Convert auth.users id to UUID for our userID
    NEW.email,            -- Use email from auth.users
    NEW.raw_user_meta_data->>'name',  -- Get name from metadata
    NEW.raw_user_meta_data->>'phone', -- Get phone from metadata
    0.0,                  -- Default latitude
    0.0,                  -- Default longitude
    '',                   -- Default empty address
    0.0                   -- Default field area
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users table to sync with our users table
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_auth_user_created();

-- Create policy to restrict access to user's own data
CREATE POLICY "Users can view their own data" ON "public"."users"
  FOR SELECT USING (auth.uid()::text = "userID"::text);

CREATE POLICY "Users can update their own data" ON "public"."users"
  FOR UPDATE USING (auth.uid()::text = "userID"::text);

-- Enable Row Level Security on users table
ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;

-- Ensure all authenticated users can view/edit their own data
GRANT SELECT, UPDATE ON "public"."users" TO authenticated;

-- Add trigger to sync user crop selections
CREATE OR REPLACE FUNCTION public.sync_user_selected_crops()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.users
  SET selected_crops = (
    SELECT array_agg("cropID") 
    FROM "userSelectedCrops" 
    WHERE "userID" = NEW."userID"
  )
  WHERE "userID" = NEW."userID";
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on userSelectedCrops table 
CREATE TRIGGER on_user_crop_change
  AFTER INSERT OR UPDATE OR DELETE ON "userSelectedCrops"
  FOR EACH ROW EXECUTE PROCEDURE public.sync_user_selected_crops();

-- When setting up in Supabase, enable the following auth settings:
-- 1. Enable email auth provider
-- 2. Enable email confirmations
-- 3. Allow sign up (enable/disable based on your requirements)
-- 4. Set proper site URL in project settings

-- Example query to manually verify a user (for testing/admin purposes)
-- UPDATE auth.users SET email_confirmed_at = NOW() WHERE email = 'user@example.com';

-- Create necessary permission policies for other tables user might need to access
-- Bookings policies
CREATE POLICY "Users can view their own bookings" ON "public"."bookings"
  FOR SELECT USING (auth.uid()::text = "userID"::text);

CREATE POLICY "Users can create their own bookings" ON "public"."bookings"
  FOR INSERT WITH CHECK (auth.uid()::text = "userID"::text);

CREATE POLICY "Users can update their own bookings" ON "public"."bookings"
  FOR UPDATE USING (auth.uid()::text = "userID"::text);

-- Reviews policies
CREATE POLICY "Users can view all reviews" ON "public"."reviews"
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own reviews" ON "public"."reviews"
  FOR INSERT WITH CHECK (auth.uid()::text = "userID"::text);

CREATE POLICY "Users can update their own reviews" ON "public"."reviews"
  FOR UPDATE USING (auth.uid()::text = "userID"::text);

-- Requests policies
CREATE POLICY "Users can view all requests" ON "public"."requests"
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own requests" ON "public"."requests"
  FOR INSERT WITH CHECK (auth.uid()::text = "userId"::text);

CREATE POLICY "Users can update their own requests" ON "public"."requests"
  FOR UPDATE USING (auth.uid()::text = "userId"::text);

CREATE POLICY "Users can delete their own requests" ON "public"."requests"
  FOR DELETE USING (auth.uid()::text = "userId"::text);

-- Enable Row Level Security on these tables
ALTER TABLE "public"."bookings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."requests" ENABLE ROW LEVEL SECURITY;

-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE ON "public"."bookings" TO authenticated;
GRANT SELECT, INSERT, UPDATE ON "public"."reviews" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "public"."requests" TO authenticated; 