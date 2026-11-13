# Instructions

## Generic rules

1. **Think before coding**. State assumptions explicitly. Ask rather than guess. Push back when a simpler approach exists. Stop when confused.
2. **Simple before complex**. Minimum code that solves the problem. Nothing speculative. No abstractions for single-use code.
3. **Surgical changes**. Touch only what you must. Don't improve adjacent code. Match existing style. Don't refactor what isn't broken.
4. **Goal-driven execution**. Define success criteria. Loop until verified. Strong success criteria let Claude loop independently.
5. **Code documentation**. Comment the why, not the what. Skip filler. No docstrings restating the signature. No section banners or change logs in code. Match the comment density of surrounding code.
6. **Write in simple technical English**. Follow ASD-STE100: short sentences, active voice, one idea per sentence. Say it once, then stop. No filler, no hype, no restating the question. Applies to all prose: answers, docs, comments, commits, PRs.
7. **Comments describe current code**. Write comments and docstrings for the code as it is now. Do not describe the previous code, removed behavior, or the change itself.
8. **New rules**. When I ask for a new rule, instruction or memory, ask me whether it should be global (`~/.claude/CLAUDE.md`, all repositories) or only for the current project (project memory) before saving it, unless I already said which.

## Before starting work

- If the work I ask for already exists (e.g. a deprecation that already landed), say so first and stop to ask before doing anything else. Check with `git log -S` or grep, open PRs (`gh pr list --search`) and branches on the remote (`git ls-remote --heads origin`) before implementing. Don't bury it in a longer reply, start related work or re-implement it in a different style.
- Use `gh` CLI to interact with GitHub. I'm @gjohansson-ST on GitHub.
- When you start work, always check out the main branch and git pull. If the repository is a fork, also make sure the fork is up to date with upstream.
- In a repository I have not contributed to before, read its contributing guide first (`CONTRIBUTING.md` in the root, `.github/` or `docs/`), before you propose an issue, a change or a PR. Check what it allows and requires, for example AI-assisted contributions, an issue before a PR, the scope of a PR, and a CLA. If the guide does not allow what I asked for, say so before you do the work. If there is no guide, say so.

## Commits

- Never commit on your own unless asked. Leave changes uncommitted in the working tree so I can review them first. Once I give approval, commit, push and open a PR.
- Commits that a routine or agent made have `Claude` as author. Before a PR is opened from them, re-author them with `git commit --amend --reset-author` and remove the `Claude-Session` trailer. Otherwise the CLA check fails.

## Git

- Before you use an existing local branch, compare it with `origin/<branch>`. A stale local branch makes the push fail.
- After a PR is open, never rebase, amend or force-push. Merge the upstream default branch into the PR branch.
- Merge with `git -c rerere.enabled=false merge ...`. rerere can reapply an old resolution that includes unrelated changes.
- Keep a merge commit to the conflict resolution and the fixes the merge requires. Put review fixes in a separate commit.
- A branch without an open PR may be rebased. Force-push it only with my approval, and only with `--force-with-lease=<branch>:<expected sha>`.
- Use a worktree when my checkout has another branch checked out. To load the work into my window:
  1. Check that my checkout has no uncommitted changes and that its branch is pushed.
  2. Save the worktree changes as a patch in the scratchpad.
  3. Remove the worktree, or detach it if the session runs inside it.
  4. Check out the branch in my checkout and `git apply` the patch.
- In a dev container, the `code` command can be missing from the PATH. Open files in my editor with `~/.vscode-server/bin/*/bin/remote-cli/code <path>`.

## Tests

- Make sure each new test fails without the fix. Remove the fix temporarily, run the test, then restore the fix.
- Never run the full test suite on my computer. Run the tests of the changed code. Let CI run the rest.

## Pull requests

- Create PRs ready for review. Only open a PR as a draft when I ask for a draft, or if an agent or skill uses `--draft`.
- Push PR branches to `origin` (the upstream repository), not to a personal fork remote such as `mine`. Create the PR with `--head <branch>` without an owner prefix. If pushing to `origin` isn't allowed, ask before falling back to a fork.
- Always print the PR URL after `gh pr create`.
- When you run locally on my computer or in my dev container, also open the PR in the browser right after `gh pr create`, with `gh pr view --web`. If that doesn't open a browser (e.g. in a devcontainer), use `"$BROWSER" <url>`. Don't open a browser in a remote or cloud session, such as Claude Code on the web or a scheduled routine.
- In every repository, read the PR template fresh from the upstream default branch right before writing each PR description, and follow it exactly. Never reuse a version from earlier in the conversation, a previous PR body, memory or a cached file.
- PR descriptions: at most 50 words in the summary section. Say what changed and why, nothing else. In your own prose: no file paths, no symbol names, no narration of the diff, no account of what you ran to verify it. Detail belongs in the commit message; the diff and the checks speak for themselves. Answer other template sections in one line each.
- Look for the template in `.github/`, the repo root, `docs/` and the `PULL_REQUEST_TEMPLATE/` folder (e.g. `git fetch <upstream> <default-branch>` then `git show <upstream>/<default-branch>:.github/PULL_REQUEST_TEMPLATE.md`). If there is none, say so instead of inventing one.
- Keep everything in the template, including unchecked checkboxes, and pass the body with `--body-file`.
- Split work into small single-purpose PRs. When a PR needs another one, write "Depends on #X, which …" and keep it in draft until #X is merged. After #X merges, change the text to "Follows #X".
- Stacked PRs: Use the stack skill
- Validate each link before you post it, for example changelog, release, diff and PR links:
  - The link loads without an error.
  - The page shows what the text says it shows, for example the correct package, versions, tag range or PR.
- After a push that changes behavior, update the PR description, and the linked docs PR when user-facing behavior changes.
- When the change fixes a failure, quote the log, stack trace, or error output that shows it, whether it opened the session or arrived later. Quoted evidence is not prose, so it does not count against the 50 words and the paths inside it are fine. Show the failure the change fixes, never output from your own verification runs. Collapse it in a `<details>` block when it runs more than about 20 lines.
- Attach images and videos with --attach <file> on gh pr and gh issue create, edit, and comment. If the Markdown already references the local file, gh rewrites that reference in place to point at the upload.
- After creating or updating a PR, monitor CI and new review comments until the PR is merged or closed, or I ask you to stop. Set up monitoring without asking me. Never leave a PR of mine with a failed check.
- Subscribe to GitHub events for CI status and new review comments if your environment permits it. If it does not, schedule timed follow-ups to check for updates.
- If CI fails, fix it and push the fix.
- Read the comments on the PR. If a comment clearly reports a bug that this PR causes, fix it. Review bots such as Copilot often report scope creep as a bug: a problem that existed before the PR, an edge case outside the goal of the PR, extra hardening, or a change to code that the PR does not touch. For those, and for every other comment, ask me before you act. If you are not sure, ask. Never post a reply on the PR yourself until I have approved it.

## Screenshots from a fork

- `gh pr create --attach` (and `edit` or `comment`) needs write access to the upstream repository and fails with "attaching files requires write access to the repository" when the user only has triage access. When the pull request comes from a fork, upload the file against the fork instead, through the same endpoint gh uses, and use the returned URL in the body:

```sh
gh api repos/<owner>/<fork> --jq .id
gh api -X POST "https://uploads.github.com/user-attachments/assets?name=<file>.png&content_type=image/png&repository_id=<fork id>" -H "Content-Type: application/octet-stream" --input <path to file> --jq .url
```

The forks have issues turned off, so don't try a throwaway issue. The returned link renders in the pull request.

## Review comments

- Check each claim of a bot reviewer (Copilot and others) against the code before you change anything. Some claims are wrong.
- Reply to a comment, resolve a thread, mark a PR ready or post any comment only when I ask. Show me the text first when I have not given it.
- Never reply to a comment or review that only asks to fix merge conflicts. Fixing the conflicts is enough.
- A "changes requested" review that is already addressed stays until the reviewer re-reviews. Tell me. Do not ask the reviewer yourself.

## Other information

- In Markdown rendered on GitHub (PR descriptions, comments, issues, etc.), a single newline is rendered as an actual line break. This is off-spec from standard Markdown. So do NOT hard-wrap text to a column width in GitHub Markdown; let paragraphs flow on a single line and only insert newlines where you genuinely want a line break.