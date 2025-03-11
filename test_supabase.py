from supabase import create_client
import os

# Supabase credentials
supabase_url = "https://bfzdljnalladqtdoaijb.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmemRsam5hbGxhZHF0ZG9haWpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE1MjcwMzksImV4cCI6MjA1NzEwMzAzOX0.UXYL9k86jgetDyQrKYeQs6IHnXydtROxC8UODM8vD-w"

try:
    # Initialize Supabase client
    supabase = create_client(supabase_url, supabase_key)
    
    # SQL commands to set up the database
    setup_commands = [
        # Enable vector extension
        "create extension if not exists vector;",
        
        # Create the table
        """
        create table if not exists site_pages (
            id bigserial primary key,
            url varchar not null,
            chunk_number integer not null,
            title varchar not null,
            summary varchar not null,
            content text not null,
            metadata jsonb not null default '{}'::jsonb,
            embedding vector(1536),
            created_at timestamp with time zone default timezone('utc'::text, now()) not null,
            unique(url, chunk_number)
        );
        """,
        
        # Create indexes
        "create index if not exists on site_pages using ivfflat (embedding vector_cosine_ops);",
        "create index if not exists idx_site_pages_metadata on site_pages using gin (metadata);",
        
        # Create the search function
        """
        create or replace function match_site_pages (
            query_embedding vector(1536),
            match_count int default 10,
            filter jsonb DEFAULT '{}'::jsonb
        ) returns table (
            id bigint,
            url varchar,
            chunk_number integer,
            title varchar,
            summary varchar,
            content text,
            metadata jsonb,
            similarity float
        )
        language plpgsql
        as $$
        #variable_conflict use_column
        begin
            return query
            select
                id,
                url,
                chunk_number,
                title,
                summary,
                content,
                metadata,
                1 - (site_pages.embedding <=> query_embedding) as similarity
            from site_pages
            where metadata @> filter
            order by site_pages.embedding <=> query_embedding
            limit match_count;
        end;
        $$;
        """,
        
        # Enable RLS
        "alter table site_pages enable row level security;",
        
        # Create public read policy
        """
        create policy if not exists "Allow public read access"
            on site_pages
            for select
            to public
            using (true);
        """
    ]
    
    # Execute each command
    for cmd in setup_commands:
        try:
            result = supabase.rpc('exec_sql', {'query': cmd}).execute()
            print(f"Successfully executed SQL command")
        except Exception as e:
            print(f"Error executing command: {e}")
            print("Command was:", cmd)
    
    # Test the connection and table
    result = supabase.table('site_pages').select("*").execute()
    print("\nDatabase setup complete!")
    print("Current records in site_pages:", len(result.data))
    
except Exception as e:
    print("Error connecting to Supabase:")
    print(e) 