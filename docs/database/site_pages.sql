-- Drop existing objects
DROP TABLE IF EXISTS site_pages CASCADE;
DROP FUNCTION IF EXISTS match_site_pages;

-- Enable the pgvector extension
create extension if not exists vector;

-- Create the documentation chunks table
create table site_pages (
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

-- Create an index for better vector similarity search performance
create index on site_pages using ivfflat (embedding vector_cosine_ops);

-- Create an index on metadata for faster filtering
create index idx_site_pages_metadata on site_pages using gin (metadata);

-- Create a function to search for documentation chunks
create function match_site_pages (
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

-- Enable RLS on the table
alter table site_pages enable row level security;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow service role full access" ON site_pages;
DROP POLICY IF EXISTS "Allow public read access" ON site_pages;
DROP POLICY IF EXISTS "Allow insert" ON site_pages;
DROP POLICY IF EXISTS "Allow delete" ON site_pages;

-- Create policies for different operations
create policy "Allow public read access"
  on site_pages
  for select
  to public
  using (true);

create policy "Allow insert"
  on site_pages
  for insert
  with check (true);

create policy "Allow delete"
  on site_pages
  for delete
  using (true);

-- Grant necessary permissions to service_role
grant all privileges on table site_pages to service_role;
grant usage on sequence site_pages_id_seq to service_role;

-- Grant read-only access to authenticated and anon roles
GRANT SELECT ON TABLE site_pages TO authenticated;
GRANT SELECT ON TABLE site_pages TO anon;

-- Allow service_role to bypass RLS entirely
ALTER ROLE service_role WITH BYPASSRLS; 