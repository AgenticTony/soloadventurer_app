-- Drop existing objects
DROP TABLE IF EXISTS site_pages CASCADE;
DROP FUNCTION IF EXISTS match_site_pages;
DROP FUNCTION IF EXISTS match_site_pages_with_score;

-- Enable the pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create the documentation chunks table
CREATE TABLE site_pages (
    id bigserial primary key,
    url varchar not null,
    chunk_number integer not null,
    title varchar not null,
    summary varchar not null,
    content text not null,
    metadata jsonb not null default '{}'::jsonb,
    embedding vector(768),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(url, chunk_number)
);

-- Create a more efficient index for vector similarity search
CREATE INDEX site_pages_embedding_idx ON site_pages 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Create an index on metadata for faster filtering
CREATE INDEX idx_site_pages_metadata ON site_pages USING gin (metadata);

-- Create an index on url and chunk_number for faster lookups
CREATE INDEX idx_site_pages_url_chunk ON site_pages (url, chunk_number);

-- Create a function to search for documentation chunks with cosine similarity
CREATE FUNCTION match_site_pages (
  query_embedding vector(768),
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
    1 - (embedding <=> query_embedding) as similarity
  FROM site_pages
  WHERE metadata @> filter
    AND embedding IS NOT NULL
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Create a function to search with minimum similarity threshold
CREATE FUNCTION match_site_pages_with_score (
  query_embedding vector(768),
  match_threshold float DEFAULT 0.7,
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
    1 - (embedding <=> query_embedding) as similarity
  FROM site_pages
  WHERE metadata @> filter
    AND embedding IS NOT NULL
    AND 1 - (embedding <=> query_embedding) >= match_threshold
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Enable RLS on the table
ALTER TABLE site_pages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow service role full access" ON site_pages;
DROP POLICY IF EXISTS "Allow public read access" ON site_pages;
DROP POLICY IF EXISTS "Allow insert" ON site_pages;
DROP POLICY IF EXISTS "Allow delete" ON site_pages;

-- Create policies for different operations
CREATE POLICY "Allow public read access"
  ON site_pages
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow insert"
  ON site_pages
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow delete"
  ON site_pages
  FOR DELETE
  USING (true);

-- Grant necessary permissions to service_role
GRANT ALL PRIVILEGES ON TABLE site_pages TO service_role;
GRANT USAGE ON SEQUENCE site_pages_id_seq TO service_role;

-- Grant read-only access to authenticated and anon roles
GRANT SELECT ON TABLE site_pages TO authenticated;
GRANT SELECT ON TABLE site_pages TO anon;

-- Create an index on created_at for time-based queries
CREATE INDEX idx_site_pages_created_at ON site_pages (created_at); 