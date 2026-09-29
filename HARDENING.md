<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/4.0.0** was hardened automatically. 15 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are directly interpolated into run: shell command strings in action.yml. GitHub Actions performs YAML template substitution before the shell parses the string, so any attacker-controlled value (inputs.*, steps.*.outputs.*, runner.*) can inject arbitrary shell commands.

Affected steps and offending expressions:

1. "Determine whether we should ignore caching" (line 57): `${{ inputs.ignore-cache }}` interpolated directly into the shell command string.

2. "Determine Composer paths" (lines 63-66): `${{ inputs.working-directory }}`, `${{ steps.php.outputs.path }}`, `${{ inputs.composer-filename }}` interpolated directly into the shell command.

3. "Determine cache key" (lines 72-79): `${{ runner.os }}`, `${{ steps.php.outputs.version }}`, `${{ inputs.dependency-versions }}`, `${{ inputs.composer-options }}`, `${{ inputs.custom-cache-key }}`, `${{ inputs.custom-cache-suffix }}`, `${{ inputs.working-directory }}` all interpolated directly into the shell command.

4. "Install Composer dependencies" (lines 88-95): `${{ inputs.dependency-versions }}`, `${{ inputs.composer-options }}`, `${{ inputs.working-directory }}`, `${{ steps.php.outputs.path }}`, `${{ steps.composer.outputs.composer_command }}`, `${{ steps.composer.outputs.lock }}`, `${{ inputs.require-lock-file }}`, `${{ inputs.composer-filename }}` all interpolated directly into the shell command.

Fix: Move all ${{ }} values into env: variables and reference them as quoted shell variables (e.g., "$INPUT_IGNORE_CACHE") inside the run: block.

Locations:

- `action.yml:57`
- `action.yml:62`
- `action.yml:71`
- `action.yml:87`

### github-env-injection (severity: high)

bin/cache_key.sh writes values derived from untrusted inputs to $GITHUB_OUTPUT and $GITHUB_ENV without the required sanitization step (printf '%s' "$VAR" | tr -d '\n\r').

1. Line 44 of cache_key.sh: `echo "key=${cache_key}" >> "${GITHUB_OUTPUT}"` — cache_key is built from positional arguments that include inputs.custom-cache-key, inputs.composer-options, inputs.custom-cache-suffix, and inputs.working-directory (all passed as ${{ inputs.* }} from action.yml line 71-79). A newline embedded in any of these inputs can inject additional key=value pairs into GITHUB_OUTPUT.

2. Lines 47-51 of cache_key.sh: A heredoc block writes CACHE_RESTORE_KEY to $GITHUB_ENV without sanitization. The restore key is derived from the same untrusted inputs. A newline in any input value can break out of the heredoc boundary or inject arbitrary environment variables into GITHUB_ENV.

Fix: Apply `safe=$(printf '%s' "$var" | tr -d '\n\r')` to each input-derived value immediately before writing it to $GITHUB_OUTPUT or $GITHUB_ENV.

Locations:

- `bin/cache_key.sh:44`
- `bin/cache_key.sh:47`

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

Fixed all ${{ }} expression interpolations in action.yml run: blocks by moving them to env: maps and referencing as shell variables. Fixed bin/cache_key.sh to sanitize values with `printf '%s' | tr -d '\n\r'` before writing to $GITHUB_OUTPUT and $GITHUB_ENV to prevent newline injection attacks.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed bin/composer_paths.sh: replaced the direct heredoc writes to GITHUB_OUTPUT with sanitized versions. Each value (composer_path, cache_dir, composer_json, composer_lock) is now passed through `printf '%s' ... | tr -d '\n\r'` before being written to GITHUB_OUTPUT, preventing newline injection attacks from attacker-controlled inputs like `working-directory` and `composer-filename`.

