#!/usr/bin/env bash


GITHUB_API_URI="https://api.github.com"
GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"


github::get_pr_number() {
  jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH"
}

github::get_pr_total_approves(){
     local -r pr_number=$(github::get_pr_number)
     #local -r pr_number=1
     local -r body=$(curl -sSL   -H "Authorization: token ${GITHUB_TOKEN}" -H "$GITHUB_API_HEADER" "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/pulls/$pr_number/reviews?per_page=100")
     reviews=$(echo "$body" | jq --raw-output '.[] | {state: .state} | @base64')

     
    approvals=0

    for r in $reviews; do
        review="$(echo "$r" | base64 -d)"
        rState=$(echo "$review" | jq --raw-output '.state')

        if [[ "$rState" == "APPROVED" ]]; then
            approvals=$((approvals+1))
        fi
    done

    echo "${approvals}"
}

github::set_approved_label(){
    local -r label='bug'
    local -r approvals_needed=$2
    local -r approvals=$(github::get_pr_total_approves)

     if [[ "$approvals" -ge "$approvals_needed" ]]; then
        
         curl -sSL \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "${API_HEADER}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "{\"labels\":[\"${label}\"]}" \
        "${GITHUB_API_URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/labels"
    else
          curl -sSL \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "${API_HEADER}" \
            -X DELETE \
            "${URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/labels/${label}"
      fi

}
