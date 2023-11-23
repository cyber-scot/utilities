import requests
import base64
import os

# Fetching values from environment variables
organisation_url = os.environ["AZP_URL"]
project = os.environ["AZP_PROJECT"]
pat_token = os.environ["AZP_TOKEN"]
api_version = "6.0-preview.4"
github_repo_url = "https://github.com/cyber-scot/terraform-azurerm-bastion"
yaml_path = ".azurepipelines/tf-plan.yaml"
service_connection_id = os.getenv("SERVICE_CONNECTION_ID")
pipeline_name = os.getenv("PIPELINE_NAME")

# Base64 encode PAT for authentication
try:
    b64_auth = base64.b64encode(f":{pat_token}".encode()).decode()
except Exception as e:
    print(f"Error encoding PAT: {e}")
    exit(1)

headers = {"Authorization": f"Basic {b64_auth}", "Content-Type": "application/json"}

# Body for the API request
body = {
    "configuration": {
        "type": "yaml",
        "repository": {
            "type": "gitHub",
            "name": "cyber-scot/terraform-azurerm-bastion",
            "url": github_repo_url,
        },
        "path": yaml_path,
    },
    "name": pipeline_name,
}

# API Endpoint
url = f"{organisation_url}/{project}/_apis/pipelines?api-version=6.0-preview.1"

# Invoke REST API
try:
    response = requests.post(url, headers=headers, json=body)
    response.raise_for_status()  # Raise an exception for HTTP errors
    print(response.json())
except requests.exceptions.RequestException as e:
    print(f"Error making API request: {e}")
    exit(1)
except Exception as e:
    print(f"Unexpected error: {e}")
    exit(1)
