#!/bin/sh

cleanup() {
  rm -rf "$all_repos_temp_dir"
  rm -rf score-and-rank-contributors
}

trap 'cleanup' INT TERM EXIT

# Define remote repository for score-and-rank-contributors tool
TOOL_REPO="https://github.com/anminliu/score-and-rank-contributors.git"
REPO_LIST_FILE="config/repo_list.txt"
AUTHOR_LIST_FILE="config/author_list.txt"
all_repos_temp_dir=$(mktemp -d)

# Clone the relative repositories
git clone $TOOL_REPO score-and-rank-contributors

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


