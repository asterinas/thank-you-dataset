#!/bin/bash

cleanup() {
  rm -rf "$all_repos_temp_dir"
  rm -rf score-and-rank-contributors
}

trap 'cleanup' INT TERM EXIT

# Define remote repository for score-and-rank-contributors tool
TOOL_REPO="https://github.com/asterinas/score-and-rank-contributors" 
REPO_LIST_FILE="config/repo_list.txt"
AUTHOR_LIST_FILE="config/author_list.txt"
all_repos_temp_dir=$(mktemp -d)

# Clone the relative repositories
git clone $TOOL_REPO score-and-rank-contributors
cd score-and-rank-contributors && git checkout b1486230b1d8ab7578e5b20164030390da339e10 && cd .. 

while IFS= read -r repo_url; do
    repo_name=$(basename "$repo_url" .git)
    git clone "$repo_url" "$all_repos_temp_dir/$repo_name"
done < $REPO_LIST_FILE

# Generate datasets for each time period
./score-and-rank-contributors/score-and-rank-contributors --since $(date -d '1 year ago' +%Y-%m-%d) --authors $AUTHOR_LIST_FILE "$all_repos_temp_dir"/* > dataset/last_year.json
./score-and-rank-contributors/score-and-rank-contributors --since $(date -d '6 months ago' +%Y-%m-%d) --authors $AUTHOR_LIST_FILE "$all_repos_temp_dir"/* > dataset/last_6_months.json
./score-and-rank-contributors/score-and-rank-contributors --since $(date -d '3 months ago' +%Y-%m-%d) --authors $AUTHOR_LIST_FILE "$all_repos_temp_dir"/* > dataset/last_3_months.json
./score-and-rank-contributors/score-and-rank-contributors --since $(date -d '1 month ago' +%Y-%m-%d) --authors $AUTHOR_LIST_FILE "$all_repos_temp_dir"/* > dataset/last_month.json
./score-and-rank-contributors/score-and-rank-contributors --authors $AUTHOR_LIST_FILE "$all_repos_temp_dir"/* > dataset/all_time.json

# JSON format validator
json_files=("dataset/last_year.json" "dataset/last_6_months.json" "dataset/last_3_months.json" "dataset/last_month.json" "dataset/all_time.json")

# Function to validate JSON format
validate_json() {
    for file in "${json_files[@]}"; do
        echo "Validating $file..."
        if ! jq empty "$file"; then
            echo "Error: JSON format validation failed for $file"
            exit 1
        else
            echo "$file is a valid JSON file."
        fi
    done
}

# Call the validation function
validate_json
