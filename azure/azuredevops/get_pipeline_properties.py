import requests
import base64
import os

# Fetching values from environment variables
organisation_url = os.environ["AZP_URL"]
project = os.environ["AZP_PROJECT"]
pat_token = os.environ["AZP_TOKEN"]

# Base64 encode PAT for authentication
try:
    b64_auth = base64.b64encode(f":{pat_token}".encode()).decode()
except Exception as e:
    print(f"Error encoding PAT: {e}")
    exit(1)

headers = {"Authorization": f"Basic {b64_auth}", "Content-Type": "application/json"}

# API Endpoint to list pipelines
url = f"{organisation_url}/{project}/_apis/pipelines?api-version={api_version}"

# Invoke REST API
try:
    response = requests.get(url, headers=headers)
    response.raise_for_status()  # Raise an exception for HTTP errors
    pipelines = response.json()["value"]
    for pipeline in pipelines:
        print(pipeline)
except requests.exceptions.RequestException as e:
    print(f"Error making API request: {e}")
    exit(1)
except Exception as e:
    print(f"Unexpected error: {e}")
    exit(1)
