<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/4.0.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions into shell command strings (sub-rule a). This allows an attacker-controlled value to be injected into the shell before quoting can protect it.

1. Step 'Determine whether we should ignore caching' (line ~61): `run: '${GITHUB_ACTION_PATH}/bin/should_cache.sh "${{ inputs.ignore-cache }}"'` — inputs.ignore-cache is interpolated directly.

2. Step 'Determine Composer paths' (lines ~66-71): `"${{ inputs.working-directory }}"`, `"${{ steps.php.outputs.path }}"`, `"${{ inputs.composer-filename }}"` are all interpolated directly into the shell command.

3. Step 'Determine cache key' (lines ~77-86): `"${{ runner.os }}"`, `"${{ steps.php.outputs.version }}"`, `"${{ inputs.dependency-versions }}"`, `"${{ inputs.composer-options }}"`, `"${{ inputs.custom-cache-key }}"`, `"${{ inputs.custom-cache-suffix }}"`, `"${{ inputs.working-directory }}"` are all interpolated directly.

4. Step 'Install Composer dependencies' (lines ~98-106): `"${{ inputs.dependency-versions }}"`, `"${{ inputs.composer-options }}"`, `"${{ inputs.working-directory }}"`, `"${{ steps.php.outputs.path }}"`, `"${{ steps.composer.outputs.composer_command }}"`, `"${{ steps.composer.outputs.lock }}"`, `"${{ inputs.require-lock-file }}"`, `"${{ inputs.composer-filename }}"` are all interpolated directly.

All of these should be moved to env: variables and referenced as quoted shell variables (e.g. "$VAR") instead.

Locations:

- `action.yml:61`
- `action.yml:66`
- `action.yml:77`
- `action.yml:98`

### github-env-injection (severity: high)

Two bin/ scripts write values derived from untrusted inputs to GitHub special environment files without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. bin/cache_key.sh writes CACHE_RESTORE_KEY to $GITHUB_ENV using a heredoc containing ${uniq_restore_key[@]}, which is derived from runner_os (${{ runner.os }}), php_version (${{ steps.php.outputs.version }}), dependency_versions (${{ inputs.dependency-versions }}), composer_options (${{ inputs.composer-options }}), working_directory (${{ inputs.working-directory }}), and custom_cache_suffix (${{ inputs.custom-cache-suffix }}) — all passed as arguments from action.yml without sanitization. A newline in any of these values could inject arbitrary environment variables.

2. bin/composer_paths.sh writes lock=, json=, composer_command=, and cache-dir= to $GITHUB_OUTPUT. The lock and json values are constructed from working_directory (${{ inputs.working-directory }}) and composer_filename (${{ inputs.composer-filename }}) without sanitization, allowing newline injection into GITHUB_OUTPUT.

Locations:

- `bin/cache_key.sh:57`
- `bin/composer_paths.sh:72`

### missing-permissions (severity: medium)

The workflow file .github/workflows/continuous-integration.yml has no top-level permissions: key and none of its 6 jobs (composer, test, code-coverage, static-analysis, run, run-no-cleanup) define a job-level permissions: block. Without explicit permissions, the workflow inherits the repository default (typically write access to all scopes for private repos, or read access for public repos), granting broader access than necessary. A minimal permissions: block (e.g. contents: read) should be added at the top level or per job.

Locations:

- `.github/workflows/continuous-integration.yml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.ignore-cache }}" appears directly in run: block of step "Determine whether we should ignore caching"; move to env: map

Locations:

- `action.yml:62`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.working-directory }}" appears directly in run: block of step "Determine Composer paths"; move to env: map

Locations:

- `action.yml:69`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.composer-filename }}" appears directly in run: block of step "Determine Composer paths"; move to env: map

Locations:

- `action.yml:71`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.dependency-versions }}" appears directly in run: block of step "Determine cache key"; move to env: map

Locations:

- `action.yml:81`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.composer-options }}" appears directly in run: block of step "Determine cache key"; move to env: map

Locations:

- `action.yml:82`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.custom-cache-key }}" appears directly in run: block of step "Determine cache key"; move to env: map

Locations:

- `action.yml:84`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.custom-cache-suffix }}" appears directly in run: block of step "Determine cache key"; move to env: map

Locations:

- `action.yml:85`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.working-directory }}" appears directly in run: block of step "Determine cache key"; move to env: map

Locations:

- `action.yml:86`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.dependency-versions }}" appears directly in run: block of step "Install Composer dependencies"; move to env: map

Locations:

- `action.yml:101`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.composer-options }}" appears directly in run: block of step "Install Composer dependencies"; move to env: map

Locations:

- `action.yml:102`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.working-directory }}" appears directly in run: block of step "Install Composer dependencies"; move to env: map

Locations:

- `action.yml:103`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.require-lock-file }}" appears directly in run: block of step "Install Composer dependencies"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.composer-filename }}" appears directly in run: block of step "Install Composer dependencies"; move to env: map

Locations:

- `action.yml:108`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, missing-permissions

**Notes:**

Fixed all findings:

1. action.yml script-injection: Moved all ${{ inputs.* }}, ${{ runner.os }}, ${{ steps.*.outputs.* }} expressions out of run: blocks into env: maps for four steps ('Determine whether we should ignore caching', 'Determine Composer paths', 'Determine cache key', 'Install Composer dependencies'). Shell scripts now reference plain env vars like $IGNORE_CACHE, $WORKING_DIRECTORY, etc.

2. bin/cache_key.sh github-env-injection: Sanitized the cache key written to $GITHUB_OUTPUT using `printf '%s' ... | tr -d '\n\r'`. For the multiline heredoc written to $GITHUB_ENV, each restore key line is sanitized with `printf '%s' ... | tr -d '\r'` (newlines are structural in the heredoc format).

3. bin/composer_paths.sh github-env-injection: All four values (composer_command, cache-dir, json, lock) are now sanitized with `printf '%s' ... | tr -d '\n\r'` before being written to $GITHUB_OUTPUT.

4. .github/workflows/continuous-integration.yml missing-permissions: Added top-level `permissions: contents: read` block.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed bin/cache_key.sh line 57: changed `tr -d '\r'` to `tr -d '\n\r'` in the CACHE_RESTORE_KEY heredoc loop. This ensures that newline characters (in addition to carriage returns) are stripped from each restore key value before it is written to $GITHUB_ENV, preventing attackers from injecting additional key=value pairs via newlines embedded in user-controlled inputs such as composer-options, working-directory, or custom-cache-suffix.

