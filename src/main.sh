#!/usr/bin/env bash

source "$PR_SIZE_LABELER_HOME/src/github.sh"

main() {

  export GITHUB_TOKEN="$1"

  github::set_approved_label $2 $3
  github::merge_if_approved $3 $4
  exit $?
}
