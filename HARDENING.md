<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **ramsey--composer-install/4.0.0** was hardened automatically. 15 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ inputs.* }} and ${{ steps.*.outputs.* }} expressions into shell command strings (sub-rule a). Although the values appear double-quoted in YAML, the ${{ }} template substitution occurs before the shell parses the string, so an attacker-controlled input containing shell metacharacters (e.g., `"; malicious_cmd #`) would be injected directly into the executed command.

Affected steps and offending lines:
- "Determine whether we should ignore caching" (line 57): `run: '...should_cache.sh "${{ inputs.ignore-cache }}"'`
- "Determine Composer paths" (line 62): passes `${{ inputs.working-directory }}`, `${{ steps.php.outputs.path }}`, `${{ inputs.composer-filename }}` directly in the run: block
- "Determine cache key" (line 71): passes `${{ runner.os }}`, `${{ inputs.dependency-versions }}`, `${{ inputs.composer-options }}`, `${{ inputs.custom-cache-key }}`, `${{ inputs.custom-cache-suffix }}`, `${{ inputs.working-directory }}` directly in the run: block
- "Install Composer dependencies" (line 88): passes `${{ inputs.dependency-versions }}`, `${{ inputs.composer-options }}`, `${{ inputs.working-directory }}`, `${{ inputs.require-lock-file }}`, `${{ inputs.composer-filename }}` directly in the run: block

Fix: route all inputs through env: variables and reference them as quoted shell variables (e.g., `"$INPUT_VAR"`) inside the run: script.

Locations:

- `action.yml:57`
- `action.yml:62`
- `action.yml:71`
- `action.yml:88`

### github-env-injection (severity: high)

Several bin/ scripts write user-controlled values to $GITHUB_OUTPUT or $GITHUB_ENV without first sanitizing them with `printf '%s' "$VAR" | tr -d '\n\r'`. These values originate from ${{ inputs.* }} expressions passed as positional arguments from action.yml run: blocks. A newline character embedded in any input could inject additional key=value pairs into the special environment files, allowing an attacker to set arbitrary environment variables or outputs.

Affected writes:
- bin/cache_key.sh: `echo "key=${cache_key}" >> "${GITHUB_OUTPUT}"` — cache_key is derived from user-controlled inputs (dependency-versions, composer-options, custom-cache-key, custom-cache-suffix, working-directory)
- bin/cache_key.sh: `{ echo "CACHE_RESTORE_KEY<<EOF"; printf '%s\n' "${uniq_restore_key[@]}"; echo "EOF"; } >> "${GITHUB_ENV}"` — restore key is derived from user-controlled inputs
- bin/composer_paths.sh: `{ echo "composer_command=..."; echo "cache-dir=..."; echo "json=${composer_json}"; echo "lock=${composer_lock}"; } >> "${GITHUB_OUTPUT}"` — paths are derived from user-controlled working-directory and composer-filename inputs
- bin/should_cache.sh: `echo "do-cache=${should_cache}" >> "${GITHUB_OUTPUT}"` — derived from user-controlled ignore-cache input
- bin/php_version.sh: `echo "path=${php_path}" >> "${GITHUB_OUTPUT}"` and `echo "version=${php_version}" >> "${GITHUB_OUTPUT}"` — php_version is read from the runtime environment but could be influenced

Locations:

- `bin/cache_key.sh:52`
- `bin/cache_key.sh:57`
- `bin/composer_paths.sh:68`
- `bin/should_cache.sh:14`
- `bin/php_version.sh:17`
- `bin/php_version.sh:18`

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

Fixed all script injection and github-env-injection findings:

1. action.yml: Moved all ${{ inputs.* }}, ${{ steps.*.outputs.* }}, and ${{ runner.os }} expressions out of run: blocks into env: blocks for four affected steps (Determine whether we should ignore caching, Determine Composer paths, Determine cache key, Install Composer dependencies). Shell scripts now reference plain env vars like $IGNORE_CACHE, $WORKING_DIRECTORY, $PHP_PATH, etc.

2. bin/should_cache.sh: Sanitized should_cache value with printf/tr before writing to $GITHUB_OUTPUT.

3. bin/php_version.sh: Sanitized php_path and php_version values with printf/tr before writing to $GITHUB_OUTPUT.

4. bin/composer_paths.sh: Sanitized composer_path, cache_dir, composer_json, and composer_lock values with printf/tr before writing to $GITHUB_OUTPUT.

5. bin/cache_key.sh: Sanitized cache_key with printf/tr before writing to $GITHUB_OUTPUT, and sanitized each restore key entry in the loop before writing to $GITHUB_ENV.

