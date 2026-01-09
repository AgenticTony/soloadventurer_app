import os
import sys
import asyncio
import requests
import json
from typing import List, Dict, Any, Optional
from xml.etree import ElementTree
from dataclasses import dataclass
from datetime import datetime, timezone
from urllib.parse import urlparse
from dotenv import load_dotenv
import html2text
from openai import AsyncOpenAI
from supabase import create_client, Client
from bs4 import BeautifulSoup

# Load environment variables
load_dotenv()

# Initialize OpenAI and Supabase clients
openai_client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_KEY")
)

# Initialize HTML to Markdown converter
html_converter = html2text.HTML2Text()
html_converter.ignore_links = False
html_converter.ignore_images = False
html_converter.ignore_tables = False
html_converter.body_width = 0  # No wrapping

@dataclass
class ProcessedChunk:
    url: str
    chunk_number: int
    title: str
    summary: str
    content: str
    metadata: Dict[str, Any]
    embedding: List[float]

def chunk_text(text: str, chunk_size: int = 5000) -> List[str]:
    """Split text into chunks, respecting code blocks and paragraphs."""
    chunks = []
    start = 0
    text_length = len(text)

    while start < text_length:
        # Calculate end position
        end = start + chunk_size

        # If we're at the end of the text, just take what's left
        if end >= text_length:
            chunks.append(text[start:].strip())
            break

        # Try to find a code block boundary first (```)
        chunk = text[start:end]
        code_block = chunk.rfind('```')
        if code_block != -1 and code_block > chunk_size * 0.3:
            end = start + code_block

        # If no code block, try to break at a paragraph
        elif '\n\n' in chunk:
            # Find the last paragraph break
            last_break = chunk.rfind('\n\n')
            if last_break > chunk_size * 0.3:  # Only break if we're past 30% of chunk_size
                end = start + last_break

        # If no paragraph break, try to break at a sentence
        elif '. ' in chunk:
            # Find the last sentence break
            last_period = chunk.rfind('. ')
            if last_period > chunk_size * 0.3:  # Only break if we're past 30% of chunk_size
                end = start + last_period + 1

        # Extract chunk and clean it up
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)

        # Move start position for next chunk
        start = max(start + 1, end)

    return chunks

async def get_title_and_summary(chunk: str, url: str) -> Dict[str, str]:
    """Extract title and summary using GPT-4."""
    system_prompt = """You are an AI that extracts titles and summaries from Flutter documentation chunks.
    Return a JSON object with 'title' and 'summary' keys.
    For the title: If this seems like the start of a document, extract its title. If it's a middle chunk, derive a descriptive title.
    For the summary: Create a concise summary of the main points in this chunk.
    Keep both title and summary concise but informative."""
    
    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"URL: {url}\n\nContent:\n{chunk[:1000]}..."}  # Send first 1000 chars for context
            ],
            response_format={ "type": "json_object" }
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        print(f"Error getting title and summary: {e}")
        return {"title": "Error processing title", "summary": "Error processing summary"}

async def get_embedding(text: str) -> List[float]:
    """Get embedding vector from OpenAI."""
    try:
        response = await openai_client.embeddings.create(
            model="text-embedding-3-small",
            input=text
        )
        return response.data[0].embedding
    except Exception as e:
        print(f"Error getting embedding: {e}")
        return [0] * 1536  # Return zero vector on error

async def process_chunk(chunk: str, chunk_number: int, url: str) -> ProcessedChunk:
    """Process a single chunk of text."""
    # Get title and summary
    extracted = await get_title_and_summary(chunk, url)
    
    # Get embedding
    embedding = await get_embedding(chunk)
    
    # Create metadata
    metadata = {
        "source": "flutter_docs",
        "chunk_size": len(chunk),
        "crawled_at": datetime.now(timezone.utc).isoformat(),
        "url_path": urlparse(url).path
    }
    
    return ProcessedChunk(
        url=url,
        chunk_number=chunk_number,
        title=extracted['title'],
        summary=extracted['summary'],
        content=chunk,
        metadata=metadata,
        embedding=embedding
    )

async def insert_chunk(chunk: ProcessedChunk):
    """Insert a processed chunk into Supabase."""
    try:
        data = {
            "url": chunk.url,
            "chunk_number": chunk.chunk_number,
            "title": chunk.title,
            "summary": chunk.summary,
            "content": chunk.content,
            "metadata": chunk.metadata,
            "embedding": chunk.embedding
        }
        supabase.table("site_pages").insert(data).execute()
        print(f"Stored chunk {chunk.chunk_number} for {chunk.url}")
    except Exception as e:
        print(f"Error storing chunk: {e}")

def clean_flutter_content(html_content: str) -> str:
    """Clean and process Flutter documentation HTML content."""
    # Parse HTML
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Remove navigation elements
    for nav in soup.find_all(['nav', 'header', 'footer']):
        nav.decompose()
        
    # Remove script and style elements
    for element in soup.find_all(['script', 'style']):
        element.decompose()
    
    # Convert to markdown
    markdown_content = html_converter.handle(str(soup))
    
    # Clean up markdown
    markdown_content = markdown_content.replace('\n\n\n', '\n\n')
    
    return markdown_content

def get_flutter_docs_urls() -> List[str]:
    """Get URLs from Flutter docs."""
    base_url = "https://docs.flutter.dev"
    sections = [
        "/development",
        "/get-started",
        "/cookbook",
        "/development/ui",
        "/development/data-and-backend",
        "/development/accessibility-and-localization",
        "/development/tools",
        "/testing",
        "/deployment",
        "/release",
        "/reference/widgets"
    ]
    
    urls = []
    for section in sections:
        try:
            response = requests.get(f"{base_url}{section}")
            response.raise_for_status()
            
            # Parse HTML to find documentation links
            soup = BeautifulSoup(response.text, 'html.parser')
            for link in soup.find_all('a'):
                href = link.get('href')
                if href and href.startswith('/'):
                    full_url = f"{base_url}{href}"
                    if full_url not in urls:
                        urls.append(full_url)
            
            print(f"Found {len(urls)} URLs so far...")
            
        except Exception as e:
            print(f"Error fetching section {section}: {e}")
    
    return urls

async def process_url(url: str):
    """Process a single URL."""
    try:
        # Fetch content
        response = requests.get(url)
        response.raise_for_status()
        
        # Clean and convert content
        content = clean_flutter_content(response.text)
        
        # Split into chunks
        chunks = chunk_text(content)
        print(f"Processing {url} - {len(chunks)} chunks")
        
        # Process each chunk
        for i, chunk in enumerate(chunks):
            processed_chunk = await process_chunk(chunk, i, url)
            await insert_chunk(processed_chunk)
            
        print(f"Successfully processed: {url}")
    except Exception as e:
        print(f"Error processing {url}: {str(e)}")

async def clear_existing_docs():
    """Clear existing Flutter documentation."""
    try:
        supabase.table("site_pages").delete().eq("metadata->>source", "flutter_docs").execute()
        print("Cleared existing Flutter docs")
    except Exception as e:
        print(f"Error clearing docs: {str(e)}")

async def verify_connection():
    """Verify connection to Supabase and write access."""
    try:
        # Try to execute a test insert to verify write access
        test_data = {
            "url": "test",
            "chunk_number": 0,
            "title": "test",
            "summary": "test",
            "content": "test",
            "metadata": {"test": True},
            "embedding": [0] * 1536
        }
        supabase.table("site_pages").insert(test_data).execute()
        print("Write access verified")
        
        # Clean up test data
        supabase.table("site_pages").delete().eq("url", "test").execute()
        
    except Exception as e:
        print(f"Error verifying connection: {str(e)}")
        raise e

async def main():
    # Verify connection
    await verify_connection()
    
    # Clear existing docs
    await clear_existing_docs()
    
    # Get Flutter documentation URLs
    urls = get_flutter_docs_urls()
    if not urls:
        print("No URLs found to crawl")
        return
    
    print(f"Found {len(urls)} URLs to crawl")
    
    # Process URLs with concurrency limit
    semaphore = asyncio.Semaphore(5)  # Limit to 5 concurrent requests
    async def process_url_with_limit(url):
        async with semaphore:
            await process_url(url)
    
    # Process all URLs
    await asyncio.gather(*[process_url_with_limit(url) for url in urls])

if __name__ == "__main__":
    asyncio.run(main()) 