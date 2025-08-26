#!/bin/bash

# GitHub API base URL
API_URL="https://api.github.com"

# GitHub credentials (set these as environment variables or replace with actual values)
USERNAME="${username:-your_github_username}"
TOKEN="${token:-your_personal_access_token}"

# Repository owner and name from arguments
REPO_OWNER="$1"
REPO_NAME="$2"

# Validate input arguments
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request with basic auth and capture HTTP status
    response=$(curl -s -w "%{http_code}" -u "${USERNAME}:${TOKEN}" "$url")
    http_status="${response: -3}"
    body="${response::-3}"

    echo "$http_status"
    echo "$body"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    read http_status response <<< "$(github_api_get "$endpoint")"

    # Check for successful response
    if [[ "$http_status" != "200" ]]; then
        echo "GitHub API error (HTTP $http_status):"
        echo "$response" | jq -r '.message // "Unknown error."'
        return 1
    fi

    # Parse collaborators safely
    collaborators="$(echo "$response" | jq -r '.[]? | select(.permissions?.pull == true) | .login')"

    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main execution
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
