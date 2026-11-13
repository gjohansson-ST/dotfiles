# dotfiles

My setup for [Claude Code](https://claude.com/claude-code): my global instructions, my own skills, and the skills I import from other repositories. VS Code installs it in every dev container I open.

## Contents

| Path                              | Contents                                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------------------- |
| `config/AGENTS.md`                | My global instructions for Claude Code                                                      |
| `config/skills/`                  | My own skills                                                                               |
| `config/agents/`                  | Subagents, empty for now                                                                    |
| `SKILLS.md`                       | The list of skills                                                                          |
| `.claude-plugin/marketplace.json` | The plugin marketplace `gjohansson-skills`, with my own skills and the imported skills      |
| `install.sh`                      | Sets everything up                                                                          |
| `scripts/update_skill_imports.py` | Checks the imported skills for upstream changes                                             |
| `.github/`                        | CI, the weekly update of imported skills, and the label sync                                |
| `renovate.json`                   | Renovate config that keeps the GitHub Actions and tool versions in the workflows up to date |

### Skills

The skills are listed in [SKILLS.md](SKILLS.md), with links to each skill.

## Installation

In VS Code, set the `dotfiles.repository` setting to `gjohansson-ST/dotfiles`. When VS Code creates a dev container, it clones this repository to `~/dotfiles` and runs `install.sh`.

To install it somewhere else, clone the repository and run the script:

```sh
git clone https://github.com/gjohansson-ST/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

## How it works

`install.sh` does three things:

1. It links `config/AGENTS.md` to `~/.claude/CLAUDE.md` and `config/agents` to `~/.claude/agents`.
2. It adds this repository as the plugin marketplace `gjohansson-skills`, directly from the local clone.
3. It installs the plugins, or updates them when they are installed.

The script can run again at any time. When Claude Code is not installed, it skips the plugins. When a plugin step fails, it prints a warning and continues.

Because of the links and the local marketplace, a change in the clone applies to Claude Code without a new install. Pull the clone to get changes from GitHub, and start a new Claude Code session to load them.

`~/.claude/settings.json` is not in this repository. The plugin commands write their entries to it, so tokens and other private settings in that file stay out of git.

### Imported skills

Each imported skill is pinned to a commit in `marketplace.json`. Every Monday, the "Update imported skills" workflow checks the last upstream commit that changed each skill. When a skill changed, it opens one pull request with the new commit, and links to the skill's history and the full diff. Review the skill before you merge.

### Checks and updates

- **CI** validates the marketplace, runs `install.sh` twice in a clean home and checks that every plugin installs, and runs prettier, ShellCheck and ruff.
- **Renovate** updates the GitHub Actions. A custom manager also updates the tool versions in the workflows, marked with a `# renovate:` comment.
- **Labels** come from `.github/labels.yml`. A workflow syncs them when the file changes.

## Adding a skill

- **My own skill:** add a folder with a `SKILL.md` to `config/skills/`. The `gjohansson` plugin picks it up. Add it to `SKILLS.md`.
- **An imported skill:** read the skill first. Then add a plugin to `marketplace.json` with a `git-subdir` source: the HTTPS URL of the repository, the path of the skill, and the commit to pin. Add the plugin name to `CLAUDE_PLUGINS` in `install.sh`, and the skill to `SKILLS.md`.

## License

[Apache-2.0](LICENSE). The `writing-style` skill is adapted from [timmo001/skills](https://github.com/timmo001/skills).
