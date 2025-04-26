-- Fix handle_auth_user_created function to handle null values better
CREATE OR REPLACE FUNCTION public.handle_auth_user_created()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if we already have this user to avoid duplicate errors
  IF EXISTS (SELECT 1 FROM public.users WHERE "userID" = uuid(NEW.id)) THEN
    RETURN NEW;
  END IF;
  
  -- Insert with better null handling
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
    uuid(NEW.id),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),  -- Fallback to part of email
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),  -- Empty string if phone missing
    0.0,
    0.0,
    '',
    0.0
  );
  RETURN NEW;
EXCEPTION WHEN others THEN
  -- Log error and continue
  RAISE NOTICE 'Error creating user record: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix constraint on email column (make it accept NULL for now)
ALTER TABLE users 
ALTER COLUMN email DROP NOT NULL;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Fix column name for selected_crops to match our code
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'selectedCrops'
  ) THEN
    -- If selectedCrops doesn't exist, but selected_crops does, rename it
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'users' AND column_name = 'selected_crops'
    ) THEN
      ALTER TABLE users RENAME COLUMN selected_crops TO "selectedCrops";
    ELSE
      -- If neither exists, add the column
      ALTER TABLE users ADD COLUMN "selectedCrops" UUID[] DEFAULT '{}';
    END IF;
  END IF;
END
$$;

-- Ensure the sync_user_selected_crops function references the correct column
CREATE OR REPLACE FUNCTION public.sync_user_selected_crops()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.users
  SET "selectedCrops" = (
    SELECT array_agg("cropID") 
    FROM "userSelectedCrops" 
    WHERE "userID" = NEW."userID"
  )
  WHERE "userID" = NEW."userID";
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure RLS is properly set up for all relevant tables
DO $$
BEGIN
  -- Enable RLS on these tables if it's not already enabled
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'users' AND rowsecurity = true
  ) THEN
    ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'bookings' AND rowsecurity = true
  ) THEN
    ALTER TABLE "public"."bookings" ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'reviews' AND rowsecurity = true
  ) THEN
    ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'requests' AND rowsecurity = true
  ) THEN
    ALTER TABLE "public"."requests" ENABLE ROW LEVEL SECURITY;
  END IF;
END
$$; 