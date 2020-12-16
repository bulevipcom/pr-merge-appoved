#!/usr/bin/env bash

source "$PR_SIZE_LABELER_HOME/src/github.sh"

main() {

  export GITHUB_TOKEN="$1"

  github::get_pr_total_approves $2 $3

  exit $?
}
