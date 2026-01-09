from supabase import create_client, Client
import os
from dotenv import load_dotenv
from collections import defaultdict

load_dotenv()

supabase = create_client(
    os.getenv('SUPABASE_URL'),
    os.getenv('SUPABASE_SERVICE_KEY')
)

# Get all documents and count by source
print('\nChecking document counts...')
all_docs = supabase.table('site_pages').select('metadata->source').execute()
counts = defaultdict(int)
for doc in all_docs.data:
    source = doc.get('source', 'unknown')
    counts[source] += 1

print('\nDocument counts by source:')
for source, count in counts.items():
    print(f"{source}: {count} chunks")

# Get a sample of titles from Cognito docs
print('\nSample of Cognito document titles:')
cognito_docs = supabase.table('site_pages').select('title, url').eq('metadata->>source', 'aws_cognito_docs').limit(5).execute()
for doc in cognito_docs.data:
    print(f"- {doc['title']} ({doc['url']})")

# Get latest crawl timestamp
print('\nLatest crawl timestamp:')
latest = supabase.table('site_pages').select('metadata->crawled_at').order('created_at', desc=True).limit(1).execute()
if latest.data:
    print(f"Latest crawl: {latest.data[0].get('crawled_at', 'unknown')}") 