#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${GREEN}Starting dotfiles installation...${NC}"

# AI agent config (Claude Code)
echo
echo "** Setting up AI agent config"
mkdir -p ~/.claude
mkdir -p ~/.claude/agents
mkdir -p ~/.claude/skills
ln -sf $DOTFILES_DIR/config/AGENTS.md ~/.claude/CLAUDE.md
ln -sfn "$DOTFILES_DIR/config/agents" ~/.claude/agents
for skill in "$DOTFILES_DIR"/config/skills/*/; do
    ln -sfn "$skill" ~/.claude/skills/"$(basename "$skill")"
done

echo
echo -e "${GREEN}** Done${NC}"
