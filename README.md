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
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Build
        run: ./build.sh

      - name: Version
        id: version
        if: |
          github.event_name == 'push'
          && github.ref_name == github.event.repository.default_branch
        uses: coditory/version-action@v1
        with:
          snapshot: true

      - name: Publish Snapshot
        if: steps.version.outcome == 'success'
        env:
          NEXT_VERSION: ${{ steps.version.outputs.next_version }}
        run: |
          echo "Simulating snapshot publish to maven central with version: $NEXT_VERSION"
          echo "### Published snapshot version $NEXT_VERSION 🚀" | tee -a $GITHUB_STEP_SUMMARY
```

## References

See:
- [Other Coditory actions](https://github.com/topics/coditory-actions)
- [Coditory workflows](https://github.com/topics/coditory-workflows)

