
#!/usr/bin/env bash

set -o nounset
set -o errexit
set -x

gh_pr=""
gh_pr_info=${1:-"number"}
gh_release_type=""
gh_pr_suffix=""

gh_pr="$(gh pr view --json number -q .number 2> /dev/null || echo "")"
gh_pr_suffix="$(gh pr view --json updatedAt -q .updatedAt | base64 2> /dev/null || echo "")"

if [[ -z $gh_pr ]]; then
  gh_pr="$(gh pr list -s merged -S $(git rev-parse HEAD) --json number --jq '.[0].number?' 2> /dev/null)"
fi

gh_pr="$gh_pr"-"$gh_pr_suffix"

case $gh_pr_info in
  release_type)
    if [[ -z $gh_pr ]]; then
      echo "patch"
    else
      gh_release_type=$(gh pr view "$gh_pr" --json labels --jq '.labels[].name' 2> /dev/null | grep -e major -e minor -e patch || echo "")
      if [[ -z $gh_release_type ]]; then
        echo "patch"
      else
        echo "$gh_release_type"
      fi
    fi
    ;;
  number)
    echo "$gh_pr"
    ;;
  *)
    echo "$gh_pr"
    ;;
esac