<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/3.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **ramsey--composer-install/3.2.1** was hardened automatically. 15 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ inputs.* }}`, `${{ steps.*.outputs.* }}`, and `${{ runner.* }}` expressions into shell command strings (sub-rule a). Before the shell executes, GitHub Actions performs template substitution, so an attacker-controlled input value containing shell metacharacters (`;`, `|`, `$(...)`, etc.) would be executed as shell code.

Affected steps and offending lines:
- 'Determine whether we should ignore caching' (line 57): `run: '${GITHUB_ACTION_PATH}/bin/should_cache.sh "${{ inputs.ignore-cache }}"'`
- 'Determine Composer paths' (lines 63–65): `"${{ inputs.working-directory }}"`, `"${{ steps.php.outputs.path }}"`, `"${{ inputs.composer-filename }}"`
- 'Determine cache key' (lines 72–79): `"${{ runner.os }}"`, `"${{ steps.php.outputs.version }}"`, `"${{ inputs.dependency-versions }}"`, `"${{ inputs.composer-options }}"`, `"${{ hashFiles(...) }}"`, `"${{ inputs.custom-cache-key }}"`, `"${{ inputs.custom-cache-suffix }}"`, `"${{ inputs.working-directory }}"`
- 'Install Composer dependencies' (lines 89–96): `"${{ inputs.dependency-versions }}"`, `"${{ inputs.composer-options }}"`, `"${{ inputs.working-directory }}"`, `"${{ steps.php.outputs.path }}"`, `"${{ steps.composer.outputs.composer_command }}"`, `"${{ steps.composer.outputs.lock }}"`, `"${{ inputs.require-lock-file }}"`, `"${{ inputs.composer-filename }}"`

Fix: Move all `${{ inputs.* }}` and `${{ steps.*.outputs.* }}` values into `env:` variables and reference them as quoted shell variables (e.g., `"$INPUT_WORKING_DIR"`) inside the `run:` block.

Locations:

- `action.yml:57`
- `action.yml:63`
- `action.yml:72`
- `action.yml:89`

### github-env-injection (severity: high)

Multiple `run:` scripts write values derived from user-controlled inputs to `$GITHUB_OUTPUT` or `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline injected into these values can break out of the current key=value pair and inject arbitrary environment variables or output values.

- `bin/cache_key.sh`: Writes `cache_key` (built from user-supplied `custom_cache_key`, `composer_options`, `working_directory`, `custom_cache_suffix` positional args) to `$GITHUB_OUTPUT` (line ~48) and writes `CACHE_RESTORE_KEY` (also derived from those inputs) to `$GITHUB_ENV` (lines ~52–56) without sanitization.
- `bin/composer_paths.sh`: Writes `composer_command`, `cache-dir`, `json`, and `lock` (derived from user-controlled `working-directory` and `composer-filename` inputs) to `$GITHUB_OUTPUT` without sanitization.
- `bin/php_version.sh`: Writes `php_path` and `php_version` to `$GITHUB_OUTPUT` without sanitization.
- `bin/should_cache.sh`: Writes `do-cache` (derived from the `ignore-cache` input) to `$GITHUB_OUTPUT` without sanitization.

Fix: Apply `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` immediately before every write to `$GITHUB_OUTPUT`, `$GITHUB_ENV`, or `$GITHUB_PATH` when the value originates from user-controlled input.

Locations:

- `bin/cache_key.sh:48`
- `bin/cache_key.sh:52`
- `bin/composer_paths.sh:68`
- `bin/php_version.sh:17`
- `bin/should_cache.sh:14`

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

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all script-injection and github-env-injection findings:

1. action.yml: Moved all ${{ inputs.* }}, ${{ steps.*.outputs.* }}, and ${{ runner.* }} expressions into env: blocks for the four affected steps ('Determine whether we should ignore caching', 'Determine Composer paths', 'Determine cache key', 'Install Composer dependencies'). Shell scripts now reference plain environment variables (e.g., $IGNORE_CACHE, $WORKING_DIRECTORY) instead of inline template expressions.

2. bin/should_cache.sh: Added sanitization (printf '%s' | tr -d '\n\r') before writing 'do-cache' to $GITHUB_OUTPUT.

3. bin/php_version.sh: Added sanitization before writing 'path' and 'version' to $GITHUB_OUTPUT.

4. bin/composer_paths.sh: Added sanitization before writing 'composer_command', 'cache-dir', 'json', and 'lock' to $GITHUB_OUTPUT.

5. bin/cache_key.sh: Added sanitization before writing 'key' to $GITHUB_OUTPUT, and sanitized each restore key entry (stripping \r) before writing CACHE_RESTORE_KEY to $GITHUB_ENV.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed bin/cache_key.sh line 65: changed `tr -d '\r'` to `tr -d '\n\r'` in the loop that writes CACHE_RESTORE_KEY entries to $GITHUB_ENV via heredoc. The previous sanitization only stripped carriage returns, allowing a newline character in user-controlled inputs to escape the heredoc boundary and inject arbitrary environment variable assignments. The fix now strips both newline and carriage return characters before writing each restore key entry.

