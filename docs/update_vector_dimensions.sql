-- Function to drop the embedding column
CREATE OR REPLACE FUNCTION drop_embedding_column()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Drop the existing index if it exists
    DROP INDEX IF EXISTS site_pages_embedding_idx;
    
    -- Drop the embedding column
    ALTER TABLE site_pages DROP COLUMN IF EXISTS embedding;
END;
$$;

-- Function to create the embedding column with specified dimensions
CREATE OR REPLACE FUNCTION create_embedding_column(dimensions integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create the embedding column with the specified dimensions
    ALTER TABLE site_pages ADD COLUMN embedding vector(dimensions);
    
    -- Create an index on the embedding column
    CREATE INDEX site_pages_embedding_idx ON site_pages 
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);
END;
$$; 