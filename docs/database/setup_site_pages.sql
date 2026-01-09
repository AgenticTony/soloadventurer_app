-- Drop existing objects
DROP TABLE IF EXISTS site_pages CASCADE;
DROP FUNCTION IF EXISTS match_site_pages;

-- Enable the pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create the documentation chunks table
CREATE TABLE site_pages (
    id bigserial PRIMARY KEY,
    url varchar NOT NULL,
    chunk_number integer NOT NULL,
    title varchar NOT NULL,
    summary varchar NOT NULL,
    content text NOT NULL,
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    embedding vector(1536),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(url, chunk_number)
);

-- Create an index for better vector similarity search performance
CREATE INDEX ON site_pages USING ivfflat (embedding vector_cosine_ops);

-- Create an index on metadata for faster filtering
CREATE INDEX idx_site_pages_metadata ON site_pages USING gin (metadata);

-- Create a function to search for documentation chunks
CREATE FUNCTION match_site_pages (
  query_embedding vector(1536),
  match_count int DEFAULT 10,
  filter jsonb DEFAULT '{}'::jsonb
) RETURNS TABLE (
  id bigint,
  url varchar,
  chunk_number integer,
  title varchar,
  summary varchar,
  content text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    id,
    url,
    chunk_number,
    title,
    summary,
    content,
    metadata,
    1 - (site_pages.embedding <=> query_embedding) as similarity
  FROM site_pages
  WHERE metadata @> filter
  ORDER BY site_pages.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Set up security policies

-- First, ensure RLS is enabled
ALTER TABLE site_pages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow service role full access" ON site_pages;
DROP POLICY IF EXISTS "Allow public read access" ON site_pages;

-- Create policy for service role with full access
CREATE POLICY "Allow service role full access"
ON site_pages
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Create policy for public read access
CREATE POLICY "Allow public read access"
ON site_pages
FOR SELECT
TO PUBLIC
USING (true);

-- Grant necessary permissions to service_role
GRANT ALL ON TABLE site_pages TO service_role;
GRANT USAGE ON SEQUENCE site_pages_id_seq TO service_role;

-- Grant read-only access to authenticated and anon roles
GRANT SELECT ON TABLE site_pages TO authenticated;
GRANT SELECT ON TABLE site_pages TO anon;

-- Verify the service role has the necessary permissions
ALTER ROLE service_role WITH BYPASSRLS; 