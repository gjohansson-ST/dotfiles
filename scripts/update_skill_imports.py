#!/usr/bin/env python3
"""Open a pull request for each imported skill that changed upstream.

Reads the git-subdir imports from the marketplace, finds the last upstream
commit that changed each skill's path, and opens or updates one pull request
per import that is behind. Set DRY_RUN=1 to only print what would change.
"""

import json
import os
import re
import subprocess
from pathlib import Path

MARKETPLACE = Path(".claude-plugin/marketplace.json")
GITHUB_URL = re.compile(r"^https://github\.com/(?P<repo>[^/]+/[^/]+?)(?:\.git)?$")
DEFAULT_BRANCH = os.environ.get("DEFAULT_BRANCH", "main")
DRY_RUN = os.environ.get("DRY_RUN") == "1"


def run(*args: str) -> str:
    """Run a command and return its output."""
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout


def latest_commit(repo: str, path: str) -> str:
    """Return the last commit on the default branch that changed the path."""
    return run(
        "gh", "api", f"repos/{repo}/commits?path={path}&per_page=1", "--jq", ".[0].sha"
    ).strip()


def pr_body(skill: str, repo: str, path: str, old: str, new: str) -> str:
    """Return the pull request description."""
    return (
        f"Updates the imported `{skill}` skill from {repo} to {new[:7]}. "
        "Review the skill before merging.\n\n"
        f"- Skill history: https://github.com/{repo}/commits/{new}/{path}\n"
        f"- All changes: https://github.com/{repo}/compare/{old}...{new}\n"
    )


def update_pull_request(
    name: str, skill: str, repo: str, path: str, old: str, new: str
) -> None:
    """Commit the new pin to the plugin's branch and open or update its PR."""
    branch = f"skill-update/{name}"
    run("git", "checkout", "-B", branch, f"origin/{DEFAULT_BRANCH}")
    data = json.loads(MARKETPLACE.read_text())
    for plugin in data["plugins"]:
        if plugin["name"] == name:
            plugin["source"]["sha"] = new
    MARKETPLACE.write_text(json.dumps(data, indent=2) + "\n")
    title = f"Update the {skill} skill to {new[:7]}"
    run("git", "commit", "--all", "--message", title)
    # The branch only holds this generated commit, so it is replaced on every run
    run("git", "push", "--force", "origin", branch)

    body = pr_body(skill, repo, path, old, new)
    open_prs = run(
        "gh",
        "pr",
        "list",
        "--head",
        branch,
        "--state",
        "open",
        "--json",
        "number",
        "--jq",
        ".[].number",
    ).split()
    if open_prs:
        run("gh", "pr", "edit", open_prs[0], "--title", title, "--body", body)
    else:
        run(
            "gh",
            "pr",
            "create",
            "--base",
            DEFAULT_BRANCH,
            "--head",
            branch,
            "--title",
            title,
            "--body",
            body,
        )
    run("git", "checkout", DEFAULT_BRANCH)


def main() -> None:
    """Check each git-subdir import of the marketplace."""
    data = json.loads(MARKETPLACE.read_text())
    for plugin in data["plugins"]:
        source = plugin["source"]
        if not isinstance(source, dict) or source.get("source") != "git-subdir":
            continue
        if not (match := GITHUB_URL.match(source["url"])):
            print(f"{plugin['name']}: not on GitHub, skipped")
            continue
        repo, path, old = match["repo"], source["path"], source["sha"]
        skill = plugin.get("metadata", {}).get("skill", plugin["name"])
        new = latest_commit(repo, path)
        if not new or new == old:
            print(f"{plugin['name']}: up to date")
            continue
        print(f"{plugin['name']}: {old[:7]} -> {new[:7]}")
        if not DRY_RUN:
            update_pull_request(plugin["name"], skill, repo, path, old, new)


if __name__ == "__main__":
    main()
