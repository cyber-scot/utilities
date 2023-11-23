import requests
import base64
import os

# Fetching values from environment variables
organisation_url = os.environ["AZP_URL"]
project = os.environ["AZP_PROJECT"]
pat_token = os.environ["AZP_TOKEN"]
api_version = "6.0-preview.4"
endpoint_url = f"{organisation_url}/{project}/_apis/serviceendpoint/endpoints?api-version={api_version}"
encoded_pat = base64.b64encode(f":{pat_token}".encode("utf-8")).decode("utf-8")

headers = {"Content-Type": "application/json", "Authorization": f"Basic {encoded_pat}"}

# Make the GET request
response = requests.get(endpoint_url, headers=headers)
response_data = response.json()

# Check for a successful response
if response.status_code == 200:
    for service_connection in response_data["value"]:
        print(f"Service Connection Name: {service_connection['name']}")
        print(f"Service Connection ID: {service_connection['id']}")
        print("------")
else:
    print(f"Error: {response_data['message']}")
