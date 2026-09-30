<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/4.0.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions into shell command strings (sub-rule a). This includes attacker-controllable inputs (inputs.ignore-cache, inputs.working-directory, inputs.composer-filename, inputs.dependency-versions, inputs.composer-options, inputs.custom-cache-key, inputs.custom-cache-suffix, inputs.require-lock-file) as well as steps.*.outputs.* and runner.os. YAML template substitution occurs before the shell processes the string, so a malicious value containing shell metacharacters (;, |, $(...), etc.) can execute arbitrary commands. All ${{ }} expressions must be moved to env: variables and the env vars must be double-quoted in the shell script. Offending lines include:
- Line 58: run: '...should_cache.sh "${{ inputs.ignore-cache }}"'
- Lines 63–66: composer_paths.sh called with ${{ inputs.working-directory }}, ${{ steps.php.outputs.path }}, ${{ inputs.composer-filename }}
- Lines 72–80: cache_key.sh called with ${{ runner.os }}, ${{ steps.php.outputs.version }}, ${{ inputs.dependency-versions }}, ${{ inputs.composer-options }}, ${{ inputs.custom-cache-key }}, ${{ inputs.custom-cache-suffix }}, ${{ inputs.working-directory }}
- Lines 90–98: composer_install.sh called with ${{ inputs.dependency-versions }}, ${{ inputs.composer-options }}, ${{ inputs.working-directory }}, ${{ steps.php.outputs.path }}, ${{ steps.composer.outputs.composer_command }}, ${{ steps.composer.outputs.lock }}, ${{ inputs.require-lock-file }}, ${{ inputs.composer-filename }}

Locations:

- `action.yml:58`
- `action.yml:63`
- `action.yml:72`
- `action.yml:90`

### github-env-injection (severity: high)

bin/cache_key.sh writes user-controlled data to $GITHUB_ENV and $GITHUB_OUTPUT without sanitization. The variable `uniq_restore_key` (derived from user-supplied inputs: custom_cache_key, runner_os, dependency_versions, composer_options, working_directory, custom_cache_suffix) is written to $GITHUB_ENV using a heredoc without stripping newlines (no `printf '%s' | tr -d '\n\r'`). Similarly, `cache_key` is written to $GITHUB_OUTPUT without sanitization. An attacker-controlled input containing newlines could inject arbitrary environment variables or output parameters. The required sanitization pattern `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` must be applied before every write.

Locations:

- `bin/cache_key.sh:57`
- `bin/cache_key.sh:50`

### github-env-injection (severity: high)

bin/composer_paths.sh writes user-controlled data to $GITHUB_OUTPUT without sanitization. The variables `composer_path`, `cache_dir`, `composer_json`, and `composer_lock` are derived from user-supplied inputs (working_directory and composer_filename, passed as positional arguments from action.yml). These are written directly to $GITHUB_OUTPUT without applying `printf '%s' | tr -d '\n\r'` sanitization. A malicious value containing newlines could inject additional output parameters.

Locations:

- `bin/composer_paths.sh:71`

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection

**Notes:**

Fixed all findings across three files:

1. action.yml: Moved all ${{ }} expressions out of run: blocks and into env: blocks for four steps: 'Determine whether we should ignore caching' (1 expression), 'Determine Composer paths' (3 expressions), 'Determine cache key' (8 expressions), and 'Install Composer dependencies' (8 expressions). Shell scripts now reference plain environment variables (e.g. $INPUT_IGNORE_CACHE, $INPUT_WORKING_DIRECTORY, etc.).

2. bin/cache_key.sh: Added sanitization before writing to $GITHUB_OUTPUT (cache_key sanitized with tr -d '\n\r') and $GITHUB_ENV (each restore key item sanitized with tr -d '\r' inside the heredoc loop).

3. bin/composer_paths.sh: Replaced the heredoc block writing to $GITHUB_OUTPUT with printf statements that sanitize each value (composer_path, cache_dir, composer_json, composer_lock) using printf '%s' | tr -d '\n\r' before writing.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed bin/cache_key.sh line 57: changed `tr -d '\r'` to `tr -d '\n\r'` in the sanitization of `restore_key_item` before writing to $GITHUB_ENV via heredoc. The previous sanitization only stripped carriage returns but not newlines, allowing a newline embedded in user-controlled inputs to break the heredoc EOF delimiter and inject arbitrary KEY=VALUE pairs into $GITHUB_ENV. The fix now strips both \n and \r, consistent with the sanitization already applied to the cache key written to $GITHUB_OUTPUT.

