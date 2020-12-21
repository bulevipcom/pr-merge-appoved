# pr-approve-merge

<p align="center">
   Set label and auto merge when PR is approved by required reviewers
</p>

## 🚀 Usage

Create a file inside the `.github/workflows` directory and paste:

```yml

name: Merge when is approved

on: [pull_request]

jobs:
  merge:
    runs-on: ubuntu-latest
    name: Merge when is approved
    steps:
      - uses: actions/checkout@v1
      - uses: daniL16/pr-merge-appoved
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          required_approves: 3 
          label: 'approved'
          commit_message: 'Automerge'
           
```
