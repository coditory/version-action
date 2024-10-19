# GitHub Version Action

GitHub action that parses version tag and outputs next version

## Sample usage

```yml
name: Build

on:
  workflow_dispatch:
  pull_request:
  push:
    branches-ignore:
      - 'dependabot/**'
      - 'gh-pages'

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    # Skip duplicate build on pull_request if pull request uses branch from the same repository
    if: github.event_name != 'pull_request' || github.repository != github.event.pull_request.head.repo.full_name
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Skip build if not needed
        id: skipper
        uses: coditory/action-skipper@v1
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          skip-files: |-
            ^.gitignore
            ^[^/]*\.md
            ^.github/.*\.md
            ^docs/.*
            ^gradle.properties

      - name: Setup JDK
        uses: actions/setup-java@v4
        if: steps.skipper.outputs.skip != 'true'
        with:
          java-version: 21
          distribution: temurin
```
