import os
import sys
import asyncio
import requests
import json
from typing import List, Dict, Any, Optional, Literal
from dataclasses import dataclass
from datetime import datetime, timezone
from urllib.parse import urlparse, urljoin
from dotenv import load_dotenv
import html2text
from supabase import create_client, Client
from bs4 import BeautifulSoup
import re
import unicodedata

# Load environment variables
load_dotenv()

# Initialize Supabase client
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

# Ollama configuration
OLLAMA_BASE_URL = "http://localhost:11434"
OLLAMA_EMBED_MODEL = "nomic-embed-text"  # For embeddings only
OLLAMA_GEN_MODEL = "mistral"  # For text generation
EMBEDDING_DIMENSIONS = 768  # nomic-embed-text embeddings are 768-dimensional

DocSource = Literal[
    "flutter_docs", 
    "aws_cognito_docs", 
    "riverpod_docs",
    "aurora_docs",
    "lambda_docs",
    "api_gateway_docs",
    "cloudwatch_docs",
    "sagemaker_docs",
    "neptune_docs",
    "waf_docs",
    "shield_docs",
    "iam_docs",
    "opentelemetry_docs",
    "prometheus_docs",
    "grafana_docs",
    "kafka_docs",
    "mqtt_docs",
    "envoy_docs"
]

AWS_DOCS = {
    "aurora_docs": "https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html",
    "lambda_docs": "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html",
    "api_gateway_docs": "https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html",
    "cloudwatch_docs": "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html",
    "sagemaker_docs": "https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html",
    "neptune_docs": "https://docs.aws.amazon.com/neptune/latest/userguide/intro.html",
    "waf_docs": "https://docs.aws.amazon.com/waf/latest/developerguide/waf-chapter.html",
    "shield_docs": "https://docs.aws.amazon.com/waf/latest/developerguide/shield-chapter.html",
    "iam_docs": "https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html"
}

OPEN_SOURCE_DOCS = {
    "opentelemetry_docs": "https://opentelemetry.io/docs/",
    "prometheus_docs": "https://prometheus.io/docs/introduction/overview/",
    "grafana_docs": "https://grafana.com/docs/grafana/latest/",
    "kafka_docs": "https://kafka.apache.org/documentation/",
    "mqtt_docs": "https://mqtt.org/mqtt-specification/",
    "envoy_docs": "https://www.envoyproxy.io/docs/envoy/latest/"
}

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

        # If no paragraph break, try to break at a paragraph
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

async def get_title_and_summary_ollama(chunk: str, url: str, doc_source: DocSource) -> Dict[str, str]:
    """Extract title and summary using Ollama."""
    system_prompt = f"""You are an AI that extracts titles and summaries from {doc_source.replace('_', ' ')}.
    Return a JSON object with 'title' and 'summary' keys.
    For the title: If this seems like the start of a document, extract its title. If it's a middle chunk, derive a descriptive title.
    For the summary: Create a concise summary of the main points in this chunk.
    Keep both title and summary concise but informative.
    ONLY return valid JSON, nothing else."""
    
    try:
        # Prepare the prompt
        prompt = f"URL: {url}\n\nContent:\n{chunk[:1000]}..."
        
        # Make request to Ollama
        response = requests.post(
            f"{OLLAMA_BASE_URL}/api/generate",
            json={
                "model": OLLAMA_GEN_MODEL,  # Use generation model here
                "prompt": f"{system_prompt}\n\n{prompt}",
                "stream": False,
                "format": "json"
            }
        )
        response.raise_for_status()
        
        # Parse response
        result = response.json()
        response_text = result['response']
        
        # Extract JSON from response
        try:
            # Find JSON object in response
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1
            if json_start >= 0 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                return json.loads(json_str)
        except json.JSONDecodeError:
            pass
        
        # Fallback if JSON parsing fails
        return {
            "title": "Error processing title",
            "summary": "Error processing summary"
        }
    except Exception as e:
        print(f"Error getting title and summary from Ollama: {e}")
        return {
            "title": "Error processing title",
            "summary": "Error processing summary"
        }

async def get_embedding(text: str) -> List[float]:
    """Get embedding vector from Ollama."""
    try:
        response = requests.post(
            f"{OLLAMA_BASE_URL}/api/embeddings",
            json={
                "model": OLLAMA_EMBED_MODEL,  # Use embedding model here
                "prompt": text
            }
        )
        response.raise_for_status()
        result = response.json()
        embedding = result.get('embedding', [0] * EMBEDDING_DIMENSIONS)
        
        # Verify embedding dimensions
        if len(embedding) != EMBEDDING_DIMENSIONS:
            print(f"Warning: Got {len(embedding)} dimensions instead of {EMBEDDING_DIMENSIONS}")
            # Pad or truncate to match expected dimensions
            if len(embedding) < EMBEDDING_DIMENSIONS:
                embedding.extend([0] * (EMBEDDING_DIMENSIONS - len(embedding)))
            else:
                embedding = embedding[:EMBEDDING_DIMENSIONS]
        
        return embedding
    except Exception as e:
        print(f"Error getting embedding from Ollama: {e}")
        return [0] * EMBEDDING_DIMENSIONS  # Return zero vector on error

async def process_chunk(chunk: str, chunk_number: int, url: str, doc_source: DocSource) -> ProcessedChunk:
    """Process a single chunk of text."""
    # Get title and summary using Ollama
    extracted = await get_title_and_summary_ollama(chunk, url, doc_source)
    
    # Get embedding from Ollama
    embedding = await get_embedding(chunk)
    
    # Create metadata
    metadata = {
        "source": doc_source,
        "chunk_size": len(chunk),
        "crawled_at": datetime.now(timezone.utc).isoformat(),
        "url_path": urlparse(url).path,
        "embedding_model": f"ollama_{OLLAMA_GEN_MODEL}"  # Track which model generated the embedding
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

def clean_html_content(html_content: str) -> str:
    """Clean and process HTML content."""
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

def get_flutter_urls() -> List[str]:
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

def get_riverpod_urls() -> List[str]:
    """Get URLs from Riverpod docs."""
    base_url = "https://riverpod.dev"
    response = requests.get(f"{base_url}/docs/introduction/getting_started")
    response.raise_for_status()
    
    urls = []
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Find all documentation links in the sidebar
    for link in soup.find_all('a'):
        href = link.get('href')
        if href and '/docs/' in href:
            full_url = urljoin(base_url, href)
            if full_url not in urls:
                urls.append(full_url)
    
    return urls

def clean_text_content(content: str) -> str:
    """Clean text content by removing null bytes and other problematic characters."""
    # Remove null bytes
    content = content.replace('\x00', '')
    # Remove other control characters except newlines and tabs
    content = ''.join(char for char in content if char == '\n' or char == '\t' or (ord(char) >= 32))
    # Normalize unicode
    content = unicodedata.normalize('NFKD', content)
    return content

def get_cognito_urls() -> List[str]:
    """Get URLs from AWS Cognito docs."""
    base_url = "https://docs.aws.amazon.com/cognito"
    sections = [
        "/latest/developerguide/what-is-amazon-cognito.html",
        "/latest/developerguide/cognito-user-identity-pools.html",
        "/latest/developerguide/cognito-identity.html",
        "/latest/developerguide/authentication.html",
        "/latest/developerguide/security.html",
        "/latest/developerguide/user-pool-settings.html",
        "/latest/developerguide/cognito-integrate-apps.html",
        "/latest/developerguide/cognito-scenarios.html"
        # Removed PDF from sections
    ]
    
    urls = []
    for section in sections:
        full_url = f"{base_url}{section}"
        urls.append(full_url)
        
        try:
            response = requests.get(full_url)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            for link in soup.find_all('a'):
                href = link.get('href')
                if href and href.startswith('/cognito/latest/developerguide/') and not href.endswith('.pdf'):
                    doc_url = urljoin(base_url, href)
                    if doc_url not in urls:
                        urls.append(doc_url)
        except Exception as e:
            print(f"Error fetching section {section}: {e}")
    
    return urls

def get_aws_urls(doc_source: DocSource) -> List[str]:
    """Get URLs from AWS documentation."""
    base_url = AWS_DOCS[doc_source]
    urls = [base_url]
    
    try:
        response = requests.get(base_url)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        for link in soup.find_all('a'):
            href = link.get('href')
            if href and href.startswith('/'):
                full_url = urljoin(base_url, href)
                if full_url not in urls and doc_source.replace('_docs', '') in full_url:
                    urls.append(full_url)
    except Exception as e:
        print(f"Error fetching AWS docs for {doc_source}: {e}")
    
    return urls

def get_open_source_urls(doc_source: DocSource) -> List[str]:
    """Get URLs from open source documentation."""
    base_url = OPEN_SOURCE_DOCS[doc_source]
    urls = [base_url]
    
    try:
        response = requests.get(base_url)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        for link in soup.find_all('a'):
            href = link.get('href')
            if href:
                full_url = urljoin(base_url, href)
                if full_url not in urls and 'docs' in full_url:
                    urls.append(full_url)
    except Exception as e:
        print(f"Error fetching open source docs for {doc_source}: {e}")
    
    return urls

async def process_url(url: str, doc_source: DocSource):
    """Process a single URL."""
    try:
        # Skip PDFs for now
        if url.lower().endswith('.pdf'):
            print(f"Skipping PDF file: {url}")
            return
            
        # Fetch content
        response = requests.get(url)
        response.raise_for_status()
        
        # Clean and convert content
        content = clean_html_content(response.text)
        content = clean_text_content(content)
        
        # Split into chunks
        chunks = chunk_text(content)
        print(f"Processing {url} - {len(chunks)} chunks")
        
        # Process each chunk
        for i, chunk in enumerate(chunks, 1):
            processed_chunk = await process_chunk(chunk, i, url, doc_source)
            # Clean the content one more time before storage
            processed_chunk.content = clean_text_content(processed_chunk.content)
            await insert_chunk(processed_chunk)
            print(f"Stored chunk {i}/{len(chunks)}")
            
        print(f"Successfully processed: {url}")
    except Exception as e:
        print(f"Error processing {url}: {str(e)}")

async def clear_existing_docs(doc_source: DocSource):
    """Clear existing documentation for a specific source."""
    try:
        supabase.table("site_pages").delete().eq("metadata->>source", doc_source).execute()
        print(f"Cleared existing docs for {doc_source}")
    except Exception as e:
        print(f"Error clearing docs: {str(e)}")

async def update_vector_dimensions():
    """Update the vector dimensions in the Supabase table."""
    try:
        # Drop the existing embedding column
        supabase.table("site_pages").rpc("drop_embedding_column").execute()
        
        # Create new embedding column with correct dimensions
        supabase.table("site_pages").rpc(
            "create_embedding_column",
            {"dimensions": EMBEDDING_DIMENSIONS}
        ).execute()
        
        print(f"Updated vector dimensions to {EMBEDDING_DIMENSIONS}")
    except Exception as e:
        print(f"Error updating vector dimensions: {e}")
        raise e

async def verify_connection():
    """Verify connection to Supabase and write access."""
    try:
        print("Connected to Supabase successfully")
        
        # Try to execute a test insert to verify write access
        test_data = {
            "url": "test",
            "chunk_number": 0,
            "title": "test",
            "summary": "test",
            "content": "test",
            "metadata": {"test": True},
            "embedding": [0] * EMBEDDING_DIMENSIONS
        }
        
        # First, clean up any existing test data
        supabase.table("site_pages").delete().eq("url", "test").execute()
        
        # Try inserting test data
        supabase.table("site_pages").insert(test_data).execute()
        
        # Clean up test data
        supabase.table("site_pages").delete().eq("url", "test").execute()
        
        print("Write access verified")
        
    except Exception as e:
        print(f"Error verifying connection: {e}")
        raise e

async def main():
    # Verify connection
    await verify_connection()
    
    # Process AWS Cognito docs
    print("\nProcessing aws_cognito_docs...")
    await clear_existing_docs("aws_cognito_docs")
    cognito_urls = get_cognito_urls()
    for url in cognito_urls:
        await process_url(url, "aws_cognito_docs")
    
    # Process Flutter docs
    print("\nProcessing flutter_docs...")
    await clear_existing_docs("flutter_docs")
    flutter_urls = get_flutter_urls()
    for url in flutter_urls:
        await process_url(url, "flutter_docs")
    
    # Process Riverpod docs
    print("\nProcessing riverpod_docs...")
    await clear_existing_docs("riverpod_docs")
    riverpod_urls = get_riverpod_urls()
    for url in riverpod_urls:
        await process_url(url, "riverpod_docs")

    # Process AWS service docs
    for doc_source in AWS_DOCS.keys():
        print(f"\nProcessing {doc_source}...")
        await clear_existing_docs(doc_source)
        urls = get_aws_urls(doc_source)
        for url in urls:
            await process_url(url, doc_source)

    # Process open source docs
    for doc_source in OPEN_SOURCE_DOCS.keys():
        print(f"\nProcessing {doc_source}...")
        await clear_existing_docs(doc_source)
        urls = get_open_source_urls(doc_source)
        for url in urls:
            await process_url(url, doc_source)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProcess interrupted by user")
    except Exception as e:
        print(f"Error: {str(e)}") 