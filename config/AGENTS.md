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
- Look for the template in `.github/`, the repo root, `docs/` and the `PULL_REQUEST_TEMPLATE/` folder (e.g. `git fetch <upstream> <default-branch>` then `git show <upstream>/<default-branch>:.github/PULL_REQUEST_TEMPLATE.md`). If there is none, say so instead of inventing one.
- Keep everything in the template, including unchecked checkboxes, and pass the body with `--body-file`.
- Split work into small single-purpose PRs. When a PR needs another one, write "Depends on #X, which …" and keep it in draft until #X is merged. After #X merges, change the text to "Follows #X".
- Stacked PRs: create the PRs, then link them with `gh stack link <bottom> <top> --base <default-branch> --remote origin`. After the bottom PR merges, GitHub rebases the top branch. Move the local branch with `git reset --keep origin/<branch>` after you check that the patch is the same.
- Validate each link before you post it, for example changelog, release, diff and PR links:
  - The link loads without an error.
  - The page shows what the text says it shows, for example the correct package, versions, tag range or PR.
- After a push that changes behavior, update the PR description, and the linked docs PR when user-facing behavior changes.

## Review comments

- Check each claim of a bot reviewer (Copilot and others) against the code before you change anything. Some claims are wrong.
- Reply to a comment, resolve a thread, mark a PR ready or post any comment only when I ask. Show me the text first when I have not given it.
- Never reply to a comment or review that only asks to fix merge conflicts. Fixing the conflicts is enough.
- A "changes requested" review that is already addressed stays until the reviewer re-reviews. Tell me. Do not ask the reviewer yourself.
