#!/usr/bin/env bash


GITHUB_API_URI="https://api.github.com"
GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

github::get_pr_number() {
  jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH"
}

github::get_pr_total_approves(){
     local -r pr_number=$(github::get_pr_number)
     local -r body=$(curl -sSL  -H "${AUTH_HEADER}" -H "$GITHUB_API_HEADER" "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/pulls/$pr_number/reviews?per_page=100")

    review="$(echo "$r" | base64 -d)"
    rState=$(echo "$review" | jq --raw-output '.state')

    if [[ "$rState" == "APPROVED" ]]; then
      approvals=$((approvals+1))
    fi

    echo "${approvals}"
}

github::set_approved_label(){
    local -r addLabel=$1
    local -r approvals=$(github::get_pr_total_approves)
     if [[ "$approvals" -ge "$APPROVALS" ]]; then
        
         curl -sSL \
        -H "${AUTH_HEADER}" \
        -H "${API_HEADER}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "{\"labels\":[\"${addLabel}\"]}" \
        "${GITHUB_API_URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/labels"
}
