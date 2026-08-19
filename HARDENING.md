<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/3.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/3.2.1** was hardened automatically. 16 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions into shell command strings (sub-rule a). These expressions are YAML-template-substituted before the shell processes the command, so a malicious value containing shell metacharacters (;, |, $(...), backticks, etc.) can break out of the surrounding double-quotes and execute arbitrary commands. Affected expressions include: ${{ inputs.ignore-cache }}, ${{ inputs.working-directory }}, ${{ steps.php.outputs.path }}, ${{ inputs.composer-filename }}, ${{ runner.os }}, ${{ steps.php.outputs.version }}, ${{ inputs.dependency-versions }}, ${{ inputs.composer-options }}, ${{ inputs.custom-cache-key }}, ${{ inputs.custom-cache-suffix }}, ${{ steps.composer.outputs.composer_command }}, ${{ steps.composer.outputs.lock }}, ${{ inputs.require-lock-file }}. These should be passed via env: variables and then referenced as quoted shell variables.

Locations:

- `action.yml:57`
- `action.yml:63`
- `action.yml:72`
- `action.yml:91`

### github-env-injection (severity: high)

bin/cache_key.sh writes the cache key (derived from untrusted inputs: custom_cache_key, custom_cache_suffix, working_directory, composer_options, etc.) directly to $GITHUB_OUTPUT with 'echo "key=${cache_key}" >> "${GITHUB_OUTPUT}"', and writes the restore key array to $GITHUB_ENV using a heredoc block, without the required sanitization step (printf '%s' ... | tr -d '\n\r'). A newline embedded in any of these input-derived values could inject arbitrary environment variables or output variables. Similarly, bin/composer_paths.sh writes values derived from the working_directory and composer_filename inputs (composer_command, cache-dir, json, lock) to $GITHUB_OUTPUT without sanitization.

Locations:

- `bin/cache_key.sh:53`
- `bin/cache_key.sh:57`
- `bin/composer_paths.sh:71`

### missing-permissions (severity: medium)

The workflow file continuous-integration.yml has no top-level permissions: key and none of its jobs (composer, test, code-coverage, static-analysis, run, run-no-cleanup) define a job-level permissions: block. This means the workflow runs with the default GitHub token permissions, which may be broader than necessary. The workflow is triggered by pull_request and push events, making least-privilege permissions especially important.

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

1. action.yml (script-injection / static-inline-injection): Moved all ${{ ... }} expressions out of run: blocks into env: blocks for all four affected steps (should-cache, composer, cache-key, Install Composer dependencies). Each expression is now assigned to a named env var (e.g. INPUT_IGNORE_CACHE, INPUT_WORKING_DIRECTORY, etc.) and referenced as a quoted shell variable in the run: script.

2. bin/cache_key.sh (github-env-injection): Sanitized the cache_key before writing to $GITHUB_OUTPUT using `printf '%s' ... | tr -d '\n\r'`. Replaced the heredoc loop to sanitize each restore key entry individually before writing to $GITHUB_ENV.

3. bin/composer_paths.sh (github-env-injection): Replaced the unsanitized block write to $GITHUB_OUTPUT with individual printf statements that each sanitize their value with `printf '%s' ... | tr -d '\n\r'`.

4. .github/workflows/continuous-integration.yml (missing-permissions): Added top-level `permissions: contents: read` to restrict the workflow's GitHub token to the minimum required for checkout operations.

