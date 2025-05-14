-- Verify users table structure
DO $$ 
BEGIN
    -- Check if users table exists
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
        -- Create users table with correct structure
        CREATE TABLE public.users (
            "userID" UUID PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            phone TEXT NOT NULL,
            latitude DOUBLE PRECISION DEFAULT 0,
            longitude DOUBLE PRECISION DEFAULT 0,
            address TEXT,
            "fieldArea" DOUBLE PRECISION DEFAULT 0,
            "groupID" UUID,
            "selectedCrops" UUID[] DEFAULT '{}',
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        );
    ELSE
        -- Verify columns and add any missing ones
        DO $columns$ 
        BEGIN
            -- Add columns if they don't exist
            IF NOT EXISTS (SELECT FROM information_schema.columns 
                         WHERE table_schema = 'public' 
                         AND table_name = 'users' 
                         AND column_name = 'userID') THEN
                ALTER TABLE public.users ADD COLUMN "userID" UUID PRIMARY KEY;
            END IF;

            IF NOT EXISTS (SELECT FROM information_schema.columns 
                         WHERE table_schema = 'public' 
                         AND table_name = 'users' 
                         AND column_name = 'name') THEN
                ALTER TABLE public.users ADD COLUMN name TEXT NOT NULL DEFAULT '';
            END IF;

            -- Add other column checks similarly
            -- ... (repeat for each column)
        END $columns$;
    END IF;

    -- Create trigger for updated_at
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    $$ language 'plpgsql';

    -- Drop trigger if exists
    DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;

    -- Create trigger
    CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON public.users
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    -- Enable RLS
    ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

    -- Verify indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'users' AND indexname = 'users_email_idx') THEN
        CREATE INDEX users_email_idx ON public.users(email);
    END IF;

    -- Insert test user if table is empty
    IF NOT EXISTS (SELECT 1 FROM public.users LIMIT 1) THEN
        INSERT INTO public.users ("userID", name, email, phone, latitude, longitude, address, "fieldArea")
        VALUES 
            ('123e4567-e89b-12d3-a456-426614174000', 'Test Farmer', 'test@example.com', '1234567890', 28.6139, 77.2090, 'Delhi, India', 5.0);
    END IF;

END $$; 