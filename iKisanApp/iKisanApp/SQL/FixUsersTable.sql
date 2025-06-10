-- 1. Add missing selectedCrops column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'selectedCrops'
    ) THEN
        ALTER TABLE public.users 
        ADD COLUMN "selectedCrops" UUID[] DEFAULT '{}';
    END IF;
END $$;

-- 2. Add timestamps if they don't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE public.users 
        ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
    END IF;

    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE public.users 
        ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- 3. Set default values for numeric columns
ALTER TABLE public.users 
ALTER COLUMN latitude SET DEFAULT 0,
ALTER COLUMN longitude SET DEFAULT 0,
ALTER COLUMN "fieldArea" SET DEFAULT 0;

-- 4. Enable RLS and create policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view all users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;

-- Create new policies
CREATE POLICY "Users can view all users" ON public.users
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own data" ON public.users
    FOR UPDATE USING (auth.uid()::text = "userID"::text);

-- 5. Insert test users if table is empty
INSERT INTO public.users ("userID", name, email, phone, latitude, longitude, address, "fieldArea")
SELECT 
    gen_random_uuid(), 
    name, 
    email, 
    phone, 
    latitude, 
    longitude, 
    address, 
    "fieldArea"
FROM (
    VALUES 
        ('Test Farmer 1', 'farmer1@test.com', '1234567890', 28.6139, 77.2090, 'Delhi, India', 5.0),
        ('Test Farmer 2', 'farmer2@test.com', '9876543210', 28.7041, 77.1025, 'Noida, India', 7.5),
        ('Test Farmer 3', 'farmer3@test.com', '5555555555', 28.4595, 77.0266, 'Gurugram, India', 3.2)
) AS test_data(name, email, phone, latitude, longitude, address, "fieldArea")
WHERE NOT EXISTS (SELECT 1 FROM public.users LIMIT 1);

-- 6. Verify the data
SELECT COUNT(*) as user_count FROM public.users; 