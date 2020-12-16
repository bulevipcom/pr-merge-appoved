#!/usr/bin/env bash


GITHUB_API_URI="https://api.github.com"
GITHUB_API_HEADER="Accept: application/vnd.github.v3+json"

github::get_pr_number() {
  jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH"
}

github::get_pr_total_approves(){
     echo $GITHUB_TOKEN
     local -r pr_number=$(github::get_pr_number)
##
     local -r body=$(curl -sSL  -H "Authorization: token $GITHUB_TOKEN" -H "$GITHUB_API_HEADER"  "$GITHUB_API_URI/repos/$GITHUB_REPOSITORY/pulls/$pr_number")

    echo $body


}
