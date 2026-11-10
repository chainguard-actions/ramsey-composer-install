<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/4.0.0** was hardened automatically. 22 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Determine whether we should ignore caching' step puts a ${{ }} expression straight into its run: script: `run: '${GITHUB_ACTION_PATH}/bin/should_cache.sh "${{ inputs.ignore-cache }}"'`. Move the input into an env: variable and expand it as "$IGNORE_CACHE".

Locations:

- `action.yml:61`

### script-injection (severity: high)

Rule (a): the 'Determine Composer paths' step puts ${{ inputs.working-directory }}, ${{ steps.php.outputs.path }} and ${{ inputs.composer-filename }} straight into its run: script, e.g. `"${{ inputs.working-directory }}" \`. Move these values into env: variables and quote each expansion.

Locations:

- `action.yml:68`

### script-injection (severity: high)

Rule (a): the 'Determine cache key' step puts ${{ runner.os }}, ${{ steps.php.outputs.version }}, ${{ inputs.dependency-versions }}, ${{ inputs.composer-options }}, ${{ hashFiles(...) }}, ${{ inputs.custom-cache-key }}, ${{ inputs.custom-cache-suffix }} and ${{ inputs.working-directory }} straight into its run: script, e.g. `"${{ inputs.composer-options }}" \`. Move these values into env: variables and quote each expansion.

Locations:

- `action.yml:79`

### script-injection (severity: high)

Rule (a): the 'Install Composer dependencies' step puts ${{ inputs.dependency-versions }}, ${{ inputs.composer-options }}, ${{ inputs.working-directory }}, ${{ steps.php.outputs.path }}, ${{ steps.composer.outputs.composer_command }}, ${{ steps.composer.outputs.lock }}, ${{ inputs.require-lock-file }} and ${{ inputs.composer-filename }} straight into its run: script, e.g. `"${{ inputs.composer-options }}" \`. Move these values into env: variables and quote each expansion.

Locations:

- `action.yml:101`

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

### github-env-injection (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. bin/cache_key.sh writes user-controlled data to $GITHUB_ENV and $GITHUB_OUTPUT without sanitization. The variable `uniq_restore_key` (derived from user-supplied inputs: custom_cache_key, runner_os, dependency_versions, composer_options, working_directory, custom_cache_suffix) is written to $GITHUB_ENV using a heredoc without stripping newlines (no `printf '%s' | tr -d '\n\r'`). Similarly, `cache_key` is written to $GITHUB_OUTPUT without sanitization. An attacker-controlled input containing newlines could inject arbitrary environment variables or output parameters. The required sanitization pattern `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` must be applied before every write.

Locations:

- `bin/cache_key.sh:57`
- `bin/cache_key.sh:50`

### github-env-injection (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. bin/composer_paths.sh writes user-controlled data to $GITHUB_OUTPUT without sanitization. The variables `composer_path`, `cache_dir`, `composer_json`, and `composer_lock` are derived from user-supplied inputs (working_directory and composer_filename, passed as positional arguments from action.yml). These are written directly to $GITHUB_OUTPUT without applying `printf '%s' | tr -d '\n\r'` sanitization. A malicious value containing newlines could inject additional output parameters.

Locations:

- `bin/composer_paths.sh:71`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 88a2936..72ff23d 100644
--- a/action.yml
+++ b/action.yml
@@ -1,13 +1,10 @@
 name: "Install PHP Dependencies with Composer"
 author: "Ben Ramsey"
 description: >-
-  Installs and caches PHP dependencies with Composer, accepting arguments to
-  configure how and what to install.
-
+  Installs and caches PHP dependencies with Composer, accepting arguments to configure how and what to install.
 branding:
   icon: download
   color: purple
-
 inputs:
   dependency-versions:
     description: >-
@@ -41,68 +38,101 @@ inputs:
     default: "false"
   composer-filename:
     description: >-
-      The Composer filename to use, without the extension (e.g. `composer`,
-      `composer-gh-actions`, `composer-staging`). Please note: this is not a
-      path. If you need to specify a different path, use `working-directory`.
+      The Composer filename to use, without the extension (e.g. `composer`, `composer-gh-actions`, `composer-staging`). Please note: this is not a path. If you need to specify a different path, use `working-directory`.
     required: false
     default: "composer"
-
 runs:
   using: "composite"
   steps:
     - name: "Determine PHP version"
       id: "php"
       shell: "bash"
       run: "${GITHUB_ACTION_PATH}/bin/php_version.sh"
-
     - name: "Determine whether we should ignore caching"
       id: "should-cache"
       shell: "bash"
-      run: '${GITHUB_ACTION_PATH}/bin/should_cache.sh "${{ inputs.ignore-cache }}"'
-
+      env:
+        INPUT_IGNORE_CACHE: ${{ inputs.ignore-cache }}
+      run: '${GITHUB_ACTION_PATH}/bin/should_cache.sh "$INPUT_IGNORE_CACHE"'
     - name: "Determine Composer paths"
       id: "composer"
       shell: "bash"
+      env:
+        INPUT_WORKING_DIRECTORY: ${{ inputs.working-directory }}
+        PHP_PATH: ${{ steps.php.outputs.path }}
+        INPUT_COMPOSER_FILENAME: ${{ inputs.composer-filename }}
       run: |
         ${GITHUB_ACTION_PATH}/bin/composer_paths.sh \
           "" \
-          "${{ inputs.working-directory }}" \
-          "${{ steps.php.outputs.path }}" \
-          "${{ inputs.composer-filename }}"
-
+          "$INPUT_WORKING_DIRECTORY" \
+          "$PHP_PATH" \
+          "$INPUT_COMPOSER_FILENAME"
     - name: "Determine cache key"
       id: "cache-key"
       if: steps.should-cache.outputs.do-cache == 1
       shell: "bash"
+      env:
+        RUNNER_OS_INPUT: ${{ runner.os }}
+        PHP_VERSION: ${{ steps.php.outputs.version }}
+        INPUT_DEPENDENCY_VERSIONS: ${{ inputs.dependency-versions }}
+        INPUT_COMPOSER_OPTIONS: ${{ inputs.composer-options }}
+        FILES_HASH: ${{ hashFiles(format('**/{0}.json', inputs.composer-filename), format('**/{0}.lock', inputs.composer-filename)) }}
+        INPUT_CUSTOM_CACHE_KEY: ${{ inputs.custom-cache-key }}
+        INPUT_CUSTOM_CACHE_SUFFIX: ${{ inputs.custom-cache-suffix }}
+        INPUT_WORKING_DIRECTORY: ${{ inputs.working-directory }}
       run: |
         ${GITHUB_ACTION_PATH}/bin/cache_key.sh \
-          "${{ runner.os }}" \
-          "${{ steps.php.outputs.version }}" \
-          "${{ inputs.dependency-versions }}" \
-          "${{ inputs.composer-options }}" \
-          "${{ hashFiles(format('**/{0}.json', inputs.composer-filename), format('**/{0}.lock', inputs.composer-filename)) }}" \
-          "${{ inputs.custom-cache-key }}" \
-          "${{ inputs.custom-cache-suffix }}" \
-          "${{ inputs.working-directory }}"
-
+          "$RUNNER_OS_INPUT" \
+          "$PHP_VERSION" \
+          "$INPUT_DEPENDENCY_VERSIONS" \
+          "$INPUT_COMPOSER_OPTIONS" \
+          "$FILES_HASH" \
+          "$INPUT_CUSTOM_CACHE_KEY" \
+          "$INPUT_CUSTOM_CACHE_SUFFIX" \
+          "$INPUT_WORKING_DIRECTORY"
     - name: "Cache Composer dependencies"
       if: steps.should-cache.outputs.do-cache == 1
       uses: "actions/cache@cdf6c1fa76f9f475f3d7449005a359c84ca0f306" # v5.0.3
       with:
         path: "${{ steps.composer.outputs.cache-dir }}"
         key: "${{ steps.cache-key.outputs.key }}"
         restore-keys: |
           ${{ env.C
... (truncated)
```

Locations:

- `action.yml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed bin/cache_key.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/bin/cache_key.sh b/bin/cache_key.sh
index cfc4d8f..e394375 100755
--- a/bin/cache_key.sh
+++ b/bin/cache_key.sh
@@ -58,12 +58,16 @@ cache_key="$(make_key "${key[@]}")"
 echo "::debug::Cache primary key is '${cache_key}'"
 echo "::debug::Cache restore keys are '$(join_by ", " "${uniq_restore_key[@]}")'"
 
-echo "key=${cache_key}" >> "${GITHUB_OUTPUT}"
+safe_cache_key="$(printf '%s' "${cache_key}" | tr -d '\n\r')"
+echo "key=${safe_cache_key}" >> "${GITHUB_OUTPUT}"
 
 # Use an environment variable to capture the multiline restore key.
 # See: https://docs.github.com/en/actions/learn-github-actions/workflow-commands-for-github-actions#multiline-strings
 {
     echo "CACHE_RESTORE_KEY<<EOF"
-    printf '%s\n' "${uniq_restore_key[@]}"
+    for restore_key_item in "${uniq_restore_key[@]}"; do
+        safe_restore_key_item="$(printf '%s' "${restore_key_item}" | tr -d '\n\r')"
+        printf '%s\n' "${safe_restore_key_item}"
+    done
     echo "EOF"
 } >> "${GITHUB_ENV}"

```

Locations:

- `bin/cache_key.sh`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed bin/composer_paths.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/bin/composer_paths.sh b/bin/composer_paths.sh
index b988530..2dd99f4 100755
--- a/bin/composer_paths.sh
+++ b/bin/composer_paths.sh
@@ -68,8 +68,8 @@ echo "::debug::File composer.json found at '${composer_json}'"
 echo "::debug::File composer.lock path computed as '${composer_lock}'"
 echo "::debug::The COMPOSER environment variable is '${COMPOSER}'"
 {
-    echo "composer_command=${composer_path}"
-    echo "cache-dir=${cache_dir}"
-    echo "json=${composer_json}"
-    echo "lock=${composer_lock}"
+    printf 'composer_command=%s\n' "$(printf '%s' "${composer_path}" | tr -d '\n\r')"
+    printf 'cache-dir=%s\n' "$(printf '%s' "${cache_dir}" | tr -d '\n\r')"
+    printf 'json=%s\n' "$(printf '%s' "${composer_json}" | tr -d '\n\r')"
+    printf 'lock=%s\n' "$(printf '%s' "${composer_lock}" | tr -d '\n\r')"
 } >> "${GITHUB_OUTPUT}"

```

Locations:

- `bin/composer_paths.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, prior-fix

**Notes:**

action.yml: in the should-cache, composer-paths, cache-key and install steps, every inline ${{ }} expression (inputs, step outputs, runner.os, hashFiles) moved into env: and is passed to the bin/*.sh scripts as a double-quoted shell variable. Each argument is in the same position as upstream. composer-options is still passed as a single argument, as upstream did, and the script splits it. I also quoted the script paths, and left upstream's trailing backslash at the end of the install step as it was. bin/cache_key.sh: newlines are stripped from the key before it goes to GITHUB_OUTPUT and from each restore-key item before it goes to GITHUB_ENV. The fixed EOF heredoc delimiter is now a random one read from /dev/urandom on each run. bin/composer_paths.sh: newlines are stripped from composer_command, cache-dir, json and lock in separate assignments before they are written to GITHUB_OUTPUT.

