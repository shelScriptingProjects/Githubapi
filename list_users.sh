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

    # Send a GET request with basic auth
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    local response="$(github_api_get "$endpoint")"

    # Validate JSON response
    if ! echo "$response" | jq empty 2>/dev/null; then
        echo "Error: Invalid response from GitHub API."
        echo "$response"
        return 1
    fi

    # Extract collaborators with read (pull) access
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
