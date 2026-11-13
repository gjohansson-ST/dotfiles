---
name: repo-sync
description: Keep shared files in sync across my own GitHub repositories (gjohansson-ST), such as workflows, labels, Renovate and templates. Use when I ask to sync, align or compare files between my repositories, to check for drift, or to roll out one change to several of my repositories.
---

# Repo sync

Shared files in my repositories drift apart over time. This skill compares them, shows the drift, and rolls out one change to each repository with its own pull request.

Run it only when I ask. Nothing runs on a schedule.

## Repositories

| Group                 | Repository            | Default branch | Notes                                   |
| --------------------- | --------------------- | -------------- | --------------------------------------- |
| Python library        | `pysmhi`              | `main`         |                                         |
| Python library        | `pynordpool`          | `main`         |                                         |
| Python library        | `pytrafikverket`      | `master`       |                                         |
| HA custom integration | `attribute_as_sensor` | `main`         |                                         |
| HA custom integration | `response_as_sensor`  | `main`         |                                         |
| Other                 | `dotfiles`            | `main`         | Only the files under "All repositories" |

Sync only the repositories in this table. Add a repository only when I ask.

## Files

Sync only the files listed here. Each entry says which repositories get the file and how it syncs:

- **Same**: identical in each repository.
- **Per repository**: identical apart from the values named. Replace them before you compare or copy.
- **Union**: the file holds everything that any repository has. When one repository adds something, add it to all others.

### All repositories, including `dotfiles`

- `.github/labels.yml`: union. It contains every label from every repository.
- `.github/workflows/labels.yaml`: per repository, the trigger branch.
- `renovate.json`: union. It contains all rules from all repositories, without `enabledManagers`. `dotfiles` also has a custom manager for tool versions in its workflows. Keep it in `dotfiles` only.

### All Python libraries and HA custom integrations

- `.github/PULL_REQUEST_TEMPLATE.md`: same.
- `.github/release-drafter.yml`: same.
- `.github/workflows/pr-labels.yaml`: same.
- `.github/workflows/stale.yaml`: same.
- `.github/CODE_OF_CONDUCT.md`: same.
- `.github/CODEOWNERS`: same.
- `.github/FUNDING.yml`: same, with GitHub Sponsors, Ko-fi and PayPal. It replaces the libraries' `.github/FUNDING.yaml`.
- `.github/ISSUE_TEMPLATE/bug_report.md`: same, the bug report form. It replaces the libraries' `.github/ISSUE_TEMPLATE.md`.
- `.github/CONTRIBUTING.md`: per repository, the repository name in the issue and pull request links.
- `.github/workflows/release-drafter.yaml`: per repository, the trigger branch. The release header with the name and the star and sponsor line is in all repositories. The line with the required Home Assistant version is only where `hacs.json` exists.
- `.gitignore`: same. One Python-based file: the GitHub Python template, with `node_modules/`, `.DS_Store` and the pdm entries. No Visual Studio entries.

### Python libraries only

- `.github/workflows/release.yaml`: same.
- `.pre-commit-config.yaml`: per repository, the branch of `no-commit-to-branch`. Use one form of the `check-xml` entry.
- `.github/workflows/linting.yaml`: per repository, the trigger branch.
- `.github/workflows/typing.yaml`: per repository, the trigger branch.

### HA custom integrations only

- `.github/workflows/release.yaml`: per repository, the integration folder name.
- `.pre-commit-config.yaml`: same.
- `.github/workflows/hassfest.yaml`: same.
- `.github/workflows/ruff.yaml`: same.
- `.github/workflows/validate.yml`: same.
- `.vscode/launch.json`: same.
- `.vscode/tasks.json`: same.

### Compare only

- `.github/workflows/tests.yaml`: do not sync. Show it in the drift report and propose a fix only for an obvious mistake.

All other files belong to each repository, for example `LICENSE`, `README.md` and `pyproject.toml`.

## Source version

There is no fixed source repository. For each file, the drift report shows the versions that exist, and I choose the one to roll out. Suggest one: the newest version, or the one most repositories already use, and say why. For a union file, combine the versions instead.

## Drift report

Compare before you change anything:

1. Get the file list of each repository on its default branch: `gh api "repos/gjohansson-ST/<repo>/git/trees/<branch>?recursive=1"`. The blob SHA shows when two files are identical.
2. Group the shared files by content. Replace the per-repository values first, so they do not show as drift. Different versions are not drift, for example of an action, a package or a pre-commit hook. Renovate bumps them in each repository.
3. Show me the files that differ, with a short diff, and say which differences look accidental (spacing, a leftover from a copied file) and which look intended (a group or repository difference).
4. List the shared files that a repository is missing, compared with the other repositories in its group. Add a missing file only when I say so for that repository.
5. Do not change anything until I say which differences to sync.

## Rolling out a change

For each repository that needs the change:

1. Read its contributing guide and PR template fresh from the default branch.
2. Clone it into the scratchpad and create a branch from the default branch. Use the same branch name in each repository.
3. Make the change, with the per-repository values. Do not touch files that are not listed under "Files".
4. Commit, push to `origin`, and open the PR with the `maintenance` label. The `pr-labels` check requires a type label.
5. Watch CI on all PRs until the checks finish. Report the result as one table.

Do not link the PRs to each other or to other PRs or issues.
