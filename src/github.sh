#!/usr/bin/env bash


GITHUB_API_URI="https://api.github.com"
GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"


github::get_pr_number() {
  jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH"
}

github::get_pr_total_approves(){
     local -r pr_number=$(github::get_pr_number)
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
    local -r pr_number=$(github::get_pr_number)
    local -r set_label=$2
    local -r approvals_needed=$1
    local -r approvals=$(github::get_pr_total_approves)

     if [[ "$approvals" -ge "$approvals_needed" ]]; then
        
         curl -sSL \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "${GITHUB_API_HEADER}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "{\"labels\":[\"${set_label}\"]}" \
        "${GITHUB_API_URI}/repos/${GITHUB_REPOSITORY}/issues/${pr_number}/labels"
    else
          curl -sSL \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "${GITHUB_API_HEADER}" \
            -X DELETE \
            "${GITHUB_API_URI}/repos/${GITHUB_REPOSITORY}/issues/${pr_number}/labels/${set_label}"
      fi

}


github::is_approved(){
    local -r pr_number=$(github::get_pr_number)
    local -r body=$(curl -sSL   -H "Authorization: token ${GITHUB_TOKEN}" -H "$GITHUB_API_HEADER" "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/issues/$pr_number/labels")
    approved_label='approved'
   
  labels=$(echo "$body" | jq --raw-output '.[] | .name') 
  approved=false

  for l in $labels;do
        if [[ "$l" == "$approved_label" ]]; then
            approved=true
            break
        fi
    done
    
  echo $approved
}

github::merge_if_approved(){

  local -r pr_number=$(github::get_pr_number)
  local -r approved=$(github::is_approved)
  local -r commit_message=$2
  
  if [[ $approved == 'true' ]] ; then
    curl -sSL \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "${GITHUB_API_HEADER}" \
    -X PUT \
    "${GITHUB_API_URI}/repos/${GITHUB_REPOSITORY}/pulls/${pr_number}/merge" \
    -d '{"commit_title":\"$commit_message\"}'
   fi
}

