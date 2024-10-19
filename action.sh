#!/usr/bin/env bash
set -euf -o pipefail

# List of all default env variables:
# https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables

function main() {
  local -r tagVersion="$(git tag -l 'v[0-9]*' --merged HEAD --sort=-v:refname | grep -E "^v[0-9]+.[0-9]+.[0-9]+$" | head -n 1 | cut -c2-)"
  local -r version=${tagVersion:-0.0.0}
  local -r major="$(echo "$version" | cut -d. -f1)"
  local -r minor="$(echo "$version" | cut -d. -f2)"
  local -r patch="$(echo "$version" | cut -d. -f3)"
  local nextVersion=""
  if [ -n "$MANUAL_VERSION" ]; then
    if [[ "$MANUAL_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-.+)?$ ]]; then
      nextVersion="$MANUAL_VERSION"
    else
      echo "Invalid manual version: $MANUAL_VERSION" >&2
      echo "Expected versions formats: 1.2.3, 1.2.3-some-suffix" >&2
      exit 1
    fi
  elif [ "${INCREMENT_SECTION:-patch}" == "patch" ]; then
    nextVersion="$major.$minor.$(( patch + 1 ))"
  elif [ "$INCREMENT_SECTION" == "minor" ]; then
    nextVersion="$major.$(( minor + 1 )).0"
  elif [ "$INCREMENT_SECTION" == "major" ]; then
    nextVersion="$(( major + 1 )).0.0"
  else
    echo "Unrecognized option increment section: $INCREMENT_SECTION" >&2
    exit 1
  fi
  local -r branch="$(git branch --show-current 2>/dev/null)"
  if [ "$branch" != "$DEFAULT_BRANCH" ] && [ "$(echo "$nextVersion" | cut -d. -f1)" != "$major" ]; then
    echo "New major version can be created only from the $DEFAULT_BRANCH branch (default branch)" >&2
    exit 1
  fi
  if [ "$SNAPSHOT" == "false" ] && [[ "$nextVersion" =~ ^.*-SNAPSHOT$ ]]; then
    echo "Invalid manual version: $MANUAL_VERSION" >&2
    echo "Detected manual version containing SNAPSHOT suffix while snapshot version is disabled." >&2
    return 1
  fi
  if [ "$SNAPSHOT" == "true" ] && ! [[ "$nextVersion" =~ ^.*-SNAPSHOT$ ]]; then
    nextVersion="${nextVersion}-SNAPSHOT"
  fi
  echo "version=$version" | tee -a $GITHUB_OUTPUT
  echo "next_version=$nextVersion" | tee -a $GITHUB_OUTPUT
}

main
