-- Verify and fix requests table structure
DO $$ 
BEGIN
    -- Check if requests table exists
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'requests') THEN
        -- Create requests table with correct structure
        CREATE TABLE public.requests (
            id uuid NOT NULL,
            "userId" uuid NULL,
            "equipmentId" uuid NULL,
            "requestedDate" timestamp without time zone NOT NULL,
            status public.booking_status_enum NOT NULL,
            type public.booking_type_enum NOT NULL,
            area double precision NOT NULL,
            "timeSlot" public.time_slot_enum NOT NULL,
            "timePeriod" text NULL,
            location text NOT NULL,
            "typeOfRequest" public.request_type_enum NOT NULL,
            "selectedUsersIds" uuid[] DEFAULT '{}',
            "joinedFarmers" uuid[] DEFAULT '{}',
            created_at timestamptz DEFAULT now(),
            updated_at timestamptz DEFAULT now(),
            CONSTRAINT requests_pkey PRIMARY KEY (id),
            CONSTRAINT requests_equipmentId_fkey FOREIGN KEY ("equipmentId") REFERENCES equipment ("equipmentID") ON DELETE CASCADE,
            CONSTRAINT requests_userId_fkey FOREIGN KEY ("userId") REFERENCES users ("userID") ON DELETE CASCADE
        );

        -- Create RLS policies
        ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;

        -- Allow users to view their own requests and requests they're part of
        CREATE POLICY "Users can view their own requests and shared requests"
        ON public.requests FOR SELECT
        USING (
            auth.uid()::text = "userId"::text
            OR auth.uid()::text = ANY("selectedUsersIds"::text[])
        );

        -- Allow users to insert their own requests
        CREATE POLICY "Users can create their own requests"
        ON public.requests FOR INSERT
        WITH CHECK (auth.uid()::text = "userId"::text);

        -- Allow users to update their own requests
        CREATE POLICY "Users can update their own requests"
        ON public.requests FOR UPDATE
        USING (auth.uid()::text = "userId"::text);

        -- Allow users to delete their own requests
        CREATE POLICY "Users can delete their own requests"
        ON public.requests FOR DELETE
        USING (auth.uid()::text = "userId"::text);

        -- Create indexes for better performance
        CREATE INDEX idx_requests_userId ON public.requests("userId");
        CREATE INDEX idx_requests_equipmentId ON public.requests("equipmentId");
        CREATE INDEX idx_requests_requestedDate ON public.requests("requestedDate");
    END IF;
END $$; 