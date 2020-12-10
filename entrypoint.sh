#!/bin/bash
set -e
echo "~~~~ Start Creating PR action  ~~~~"
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Undefined GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ "$1" == ^[a-z]{1,10}-pr:[[:space:]].+ ]]; then
  COMMIT_MESSAGE='$(jq -r "$1" "$GITHUB_EVENT_PATH" | head -1)'
  REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
  DEFAULT_BRANCH=$(jq -r ".repository.default_branch" "$GITHUB_EVENT_PATH")

  echo "~~~~ Data ~~~~"
  echo "
  title : $COMMIT_MESSAGE
  ref   : $GITHUB_REF
  "

  RESPONSE_CODE=$(curl -o .output -s -w "%{http_code}\n" \
    --data "{\"title\":\"$COMMIT_MESSAGE\", \"head\": \"$GITHUB_REF\", \"base\": \"$DEFAULT_BRANCH\"}" \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO_FULLNAME/pulls")

fi
