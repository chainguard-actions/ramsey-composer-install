<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/4.0.0** was hardened automatically. 15 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions into shell command strings. This includes user-controlled inputs (inputs.ignore-cache, inputs.working-directory, inputs.composer-filename, inputs.dependency-versions, inputs.composer-options, inputs.custom-cache-key, inputs.custom-cache-suffix, inputs.require-lock-file) and step outputs (steps.php.outputs.path, steps.php.outputs.version, steps.composer.outputs.*). An attacker who controls these values can break out of the quoted argument and inject arbitrary shell commands. Affected steps: 'Determine whether we should ignore caching' (run: '..."${{ inputs.ignore-cache }}"'), 'Determine Composer paths' (run: | ... "${{ inputs.working-directory }}" ...), 'Determine cache key' (run: | ... "${{ runner.os }}" ... "${{ inputs.dependency-versions }}" ...), and 'Install Composer dependencies' (run: | ... "${{ inputs.dependency-versions }}" ...). All ${{ }} expressions must be moved to env: variables and the shell expansions must be double-quoted.

Locations:

- `action.yml:59`
- `action.yml:63`
- `action.yml:71`
- `action.yml:85`

### github-env-injection (severity: high)

Multiple bin/ scripts write user-controlled values to $GITHUB_OUTPUT and $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). (1) bin/cache_key.sh: writes 'key=${cache_key}' to $GITHUB_OUTPUT and a multiline CACHE_RESTORE_KEY to $GITHUB_ENV — both derived from user-controlled inputs (composer-options, custom-cache-key, custom-cache-suffix, working-directory) passed as positional arguments from action.yml's ${{ inputs.* }} interpolations. (2) bin/should_cache.sh: writes 'do-cache=${should_cache}' to $GITHUB_OUTPUT — derived from the user-controlled ignore-cache input. (3) bin/composer_paths.sh: writes composer_command, cache-dir, json, and lock to $GITHUB_OUTPUT — values derived from user-controlled working-directory and composer-filename inputs. A newline injected into any of these values can define arbitrary environment variables or override existing ones in subsequent steps.

Locations:

- `bin/cache_key.sh:52`
- `bin/cache_key.sh:56`
- `bin/should_cache.sh:16`
- `bin/composer_paths.sh:68`

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

Fixed all findings across action.yml and three bin/ scripts:

1. action.yml - Moved all ${{ }} expressions out of run: blocks into env: blocks for four steps: 'Determine whether we should ignore caching' (INPUT_IGNORE_CACHE), 'Determine Composer paths' (INPUT_WORKING_DIRECTORY, PHP_PATH, INPUT_COMPOSER_FILENAME), 'Determine cache key' (RUNNER_OS_VAL, PHP_VERSION, INPUT_DEPENDENCY_VERSIONS, INPUT_COMPOSER_OPTIONS, FILES_HASH, INPUT_CUSTOM_CACHE_KEY, INPUT_CUSTOM_CACHE_SUFFIX, INPUT_WORKING_DIRECTORY), and 'Install Composer dependencies' (INPUT_DEPENDENCY_VERSIONS, INPUT_COMPOSER_OPTIONS, INPUT_WORKING_DIRECTORY, PHP_PATH, COMPOSER_COMMAND, COMPOSER_LOCK, INPUT_REQUIRE_LOCK_FILE, INPUT_COMPOSER_FILENAME). Shell scripts now reference plain env vars.

2. bin/should_cache.sh - Sanitized 'should_cache' value with printf | tr -d before writing to GITHUB_OUTPUT.

3. bin/composer_paths.sh - Sanitized composer_path, cache_dir, composer_json, and composer_lock values with printf | tr -d before writing to GITHUB_OUTPUT.

4. bin/cache_key.sh - Sanitized cache_key with printf | tr -d before writing to GITHUB_OUTPUT, and sanitized each restore key entry before writing the multiline CACHE_RESTORE_KEY to GITHUB_ENV.

