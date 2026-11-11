# dotfiles

A small home for portable Visual Studio Code user settings.

## Install

Back up your existing VS Code `settings.json`, then copy
[`vscode/settings.json`](vscode/settings.json) to the User folder for your
platform:

- Windows: `%APPDATA%\Code\User\settings.json`
- macOS: `~/Library/Application Support/Code/User/settings.json`
- Linux: `~/.config/Code/User/settings.json`

Create the `User` folder if it does not exist. You can also keep this file in
the repository and symlink it to that location. VS Code Settings Sync may
manage the same settings; avoid editing both copies independently.

## Settings

The starter settings format files on save and remove trailing whitespace while
ensuring files end with a newline. Add personal settings to the JSON file as
needed.
