---
name: home-assistant
description: Personal workflow for Home Assistant repositories (home-assistant/core, home-assistant.io, frontend, architecture discussions and HACS custom integrations). Covers documentation sources, the core development environment, tests, PR conventions, review lessons, quality scale PRs, deprecations and custom integration PRs. Use it whenever you work in a Home Assistant repository or on a Home Assistant pull request, review or issue.
---

# Home Assistant workflow

These rules add to `~/.claude/CLAUDE.md` and to the `AGENTS.md` of the repository. When they conflict, the repository's `AGENTS.md` wins for code, and `~/.claude/CLAUDE.md` wins for how to work with me.

## Documentation sources

- Read developer documentation and blog posts from https://contributors.home-assistant.io.
- Never use developers.home-assistant.io or the `home-assistant/developers.home-assistant` repository. They are outdated.
- For integration code and reviews in core, use the `ha-integration-knowledge` skill.

## Repositories

- **Push access**: I can push to all `home-assistant` repositories except `home-assistant/frontend`. For the frontend, push to the `gjohansson-ST` fork and open the PR with `--head gjohansson-ST:<branch>`.
- **HACS custom integrations**: I never have push access. Fork to `gjohansson-ST` with `gh repo fork <owner>/<repo> --clone` into the scratchpad. Open the PR with `--head gjohansson-ST:<branch>`. No need to ask first.
- **Custom integration releases**: before a version bump, run `gh release list -R <repo>`. If a draft release newer than the latest release exists, keep its version.
- **Custom integration sources**: the copy for the `custom-integration-sources` skill is at `/workspaces/core/config/custom_integration_sources`. Sync it with `python3 -m script.sync_custom_integrations --dest config/custom_integration_sources`.
- **Architecture discussions**: end each draft with `---` and one sentence that says it was drafted with the help of AI (Claude Code).
- **Docs PRs** (home-assistant.io): describe how features work. Never mention deprecations, breaking changes or removal versions.
- **Todo for later**: add a line under `Claude todo's` at the top of `/workspaces/core/config/TODO`. Remove the line when the PR for it is opened.

## Core development environment

- Branch names: `gj-<integration>-<topic>` in kebab-case, for example `gj-smhi-bronze`. Create new branches from `origin/dev`.
- In a worktree of `/workspaces/core`:
  - Run tests with `uv run --no-sync python3 -m pytest`. Plain `pytest` imports the code of the main checkout.
  - First run `python3 -m script.translations develop --all`. Translations are not in git.
- The shared venv can be older than dev. Signs: mypy or pylint errors in integrations the change does not touch, or a missing argument of a library.
  - Compare the version in the `manifest.json` with `uv pip show <package>`.
  - Install the required version with `uv pip install <package>==<version>`, or run `script/setup`.
- After a merge of dev, run prek only on the files I changed. Errors in other files come from the old venv. Then commit the merge with `--no-verify`, and tell me that you did.

## Tests

- Take `hass` as a typed parameter (`hass: HomeAssistant`). Never put `hass` in `@pytest.mark.usefixtures`.
- After a change to `strings.json`, regenerate translations before the tests run.
- The test fixtures check repair issue translations:
  - A test that creates an issue needs the same `translation_placeholders` and `is_fixable` value as the integration.
  - A fixable issue has no top-level `description` string.
  - For keys that do not exist on purpose, parametrize `ignore_missing_translations`.
- `freezer.tick` past 30 minutes expires the access token of `hass_client`. Use a helper that does not use HTTP auth, for example `async_get_image` of the image component.
- An integration without tests makes `codecov/patch` fail. That does not block a merge. Tell me.

## Pull requests

- Title and first commit: imperative, sentence case, no prefix, no trailing period. They are the same text.
- Proposed change: the summary follows the 50-word rule in `~/.claude/CLAUDE.md`. Say what changes and why, or what the bug was, and link where the request came from. Keep the template's HTML comments.
- The breaking change section and the quality scale checklist are template sections, not part of the 50-word summary.
- Checklist: check "understand", "tested", "local tests", "no commented code", "dev checklist", "perfect PR", "ruff", "generated code reviewed" and "reviewed two other PRs". Check "Tests have been added" only when tests were added.
- Breaking change section: fill it in for a breaking change. Write it for users: what breaks, how to fix it, why. It is published in the release notes, so it can be longer than one line. Remove the section for other changes, as the template allows.
- Type of change:
  - Removing something from an integration after its deprecation is a breaking change.
  - Removing a core API that nothing in core uses is a code quality change.
  - When the type changes on an open PR, also swap the label: `gh pr edit <n> --remove-label <old> --add-label <new>`.
- When the bugfix box is checked, ask me whether to add the PR to the next milestone.
- Docs PR: put it on the "Link to documentation pull request" line as `home-assistant/home-assistant.io#<n>`, and check the documentation box.
- For packages that are not on GitHub, link the changelog file in the sdist through the PyPI inspector.
- For a small edit to a docs PR, you can commit through the GitHub contents API on the docs PR branch.

### Quality scale PRs

- Fix gaps in separate PRs first.
- In the description, after the summary, add a `## <Tier>` checklist of every rule:
  - `- [x] rule - #PR` when a separate PR closes the gap.
  - `- [ ] rule - Exempt as …` for exempt rules.
- Add the line "Silver, Gold and Platinum rules that are already fulfilled are marked as `done`; the remaining ones are left as `todo` for now."
- In `quality_scale.yaml`, an exempt rule has a `comment:` sentence that ends with a period.
- Mark a rule `done` in the PR that implements it.

## Review lessons

- Check new code against what reviewers raised before:
  - Keep core changes out of integration PRs.
  - Do not make the code more complex to suit the tests.
  - No magic or hacky mechanisms in core. Use an explicit API.
  - `assert` only inside `if TYPE_CHECKING:`.
  - Repair issues need stable IDs. Prefer the normal config flow of the target domain over creating entries directly.
  - Strings: correct grammar ("set up" verb, "setup" noun), no strings the frontend never shows, selectors limited to valid entities.
  - Handle edge cases instead of failing halfway, for example a unique ID that is already taken during a migration.

## Deprecations

- A deprecation is due when its `breaks_in_ha_version` X.Y is at or below the dev version in `homeassistant/const.py`.
- New deprecations: set `breaks_in_ha_version` after the next release, plus:
  - 6 months for integrations.
  - 12 months for core APIs, for example helpers and constants.
- `cv.deprecated` takes `breaks_in_ha_version`.
- Use the `ha-deprecation-cleanup` skill to find due deprecations. Earlier routine runs left `deprecation-cleanup/*` branches on `origin`. Check them before you write new code.
- When you remove a deprecated feature, also check:
  - **Persistent repair issues** (`is_persistent=True`) stay in the registry. Delete them at setup.
  - **Examples and texts** that use the removed value, for example in `services.yaml` and `strings.json`.
  - **Strict schemas**: when other integrations depend on the integration (for example `frontend` on `lovelace`), a removed option must not fail validation. Use `cv.removed(<key>, raise_if_present=False)`.
  - **Migrations** that ran only in the removed mode. Check that they do not conflict with the replacement configuration.
  - **Constants** that become unused, and tests that only covered the removed path.
- Keep the deprecation tests that check the new required behavior, for example a test that a now-required option is required.
