import os
from openai import OpenAI

# Get API key from environment
api_key = "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"

# Initialize the client
client = OpenAI(api_key=api_key)

try:
    # Try to create an embedding
    response = client.embeddings.create(
        model="text-embedding-3-small",
        input="Hello, testing OpenAI embeddings!"
    )
    print("Success! The API key works for embeddings.")
    print(f"Embedding dimension: {len(response.data[0].embedding)}")

except Exception as e:
    print("Error testing the API key:")
    print(e) 