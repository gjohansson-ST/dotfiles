#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The marketplace is this repository (.claude-plugin/marketplace.json)
CLAUDE_MARKETPLACE="gjohansson-skills"
CLAUDE_PLUGINS=(gjohansson gjohansson-gh-stack)

echo -e "${GREEN}Starting dotfiles installation...${NC}"

# AI agent config (Claude Code)
echo
echo "** Setting up AI agent config"
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/config/AGENTS.md" ~/.claude/CLAUDE.md
# ln -n replaces a link, but puts the new link inside a real directory
if [ -d ~/.claude/agents ] && [ ! -L ~/.claude/agents ]; then
    rmdir ~/.claude/agents 2>/dev/null \
        || echo -e "${YELLOW}~/.claude/agents has files, not linked${NC}"
fi
if [ ! -e ~/.claude/agents ] || [ -L ~/.claude/agents ]; then
    ln -sfn "$DOTFILES_DIR/config/agents" ~/.claude/agents
fi

# Claude Code plugins
# set -e does not apply inside a function called in a condition, so each step returns on failure
setup_claude_plugins() {
    local marketplaces
    marketplaces="$(claude plugin marketplace list --json)" || return 1
    if grep -qF "\"path\": \"$DOTFILES_DIR\"" <<< "$marketplaces"; then
        claude plugin marketplace update "$CLAUDE_MARKETPLACE" || return 1
    else
        # Known from another path, for example an older clone
        if grep -qF "\"name\": \"$CLAUDE_MARKETPLACE\"" <<< "$marketplaces"; then
            claude plugin marketplace remove "$CLAUDE_MARKETPLACE" || return 1
        fi
        claude plugin marketplace add "$DOTFILES_DIR" || return 1
    fi

    local installed_plugins plugin_id failed=0
    installed_plugins="$(claude plugin list --json)" || return 1
    for plugin in "${CLAUDE_PLUGINS[@]}"; do
        plugin_id="$plugin@$CLAUDE_MARKETPLACE"
        if grep -qF "\"id\": \"$plugin_id\"" <<< "$installed_plugins"; then
            claude plugin update "$plugin_id" || failed=1
        else
            claude plugin install "$plugin_id" --scope user || failed=1
        fi
    done
    return "$failed"
}

echo
echo "** Setting up Claude Code plugins"
if ! command -v claude >/dev/null 2>&1; then
    echo -e "${YELLOW}Claude Code is not installed, skipping plugins${NC}"
elif ! setup_claude_plugins; then
    echo -e "${RED}Could not set up all Claude Code plugins${NC}"
fi

echo
echo -e "${GREEN}** Done${NC}"
