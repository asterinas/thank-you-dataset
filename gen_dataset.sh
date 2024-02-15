#!/bin/bash
set -e

cleanup() {
  rm -rf "$all_repos_temp_dir"
}

trap 'cleanup' INT TERM EXIT

# Define remote repository for score-and-rank-contributors tool
REPO_LIST_FILE="config/repo_list.txt"
AUTHOR_LIST_FILE="config/author_list.txt"
all_repos_temp_dir=$(mktemp -d)

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
        if python -m json.tool $file > /dev/null 2>&1; then
            echo "$file is a valid JSON file."
        else
            echo "Error: JSON format validation failed for $file"
            exit 1
        fi
    done
}

# Call the validation function
validate_json
