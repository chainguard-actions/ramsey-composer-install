<!-- markdownlint-disable -->

# Hardening Report: ramsey--composer-install/3.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **ramsey--composer-install/3.2.1** was hardened automatically. 23 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): a GitHub Actions expression is placed directly in a run: block in the 'Determine whether we should ignore caching' step: `run: '${GITHUB_ACTION_PATH}/bin/should_cache.sh "${{ inputs.ignore-cache }}"'`. The template is filled in before the shell parses the line, so a value containing a double quote can break out of the quoting and inject commands. Fix: pass the input through env: and use "$IGNORE_CACHE" instead.

Locations:

- `action.yml:62`

### script-injection (severity: high)

Rule (a): the 'Determine Composer paths' run block places expressions directly in the script: `"${{ inputs.working-directory }}"`, `"${{ steps.php.outputs.path }}"` and `"${{ inputs.composer-filename }}"`. Fix: map each value to an env: variable and reference it with double quotes.

Locations:

- `action.yml:67`

### script-injection (severity: high)

Rule (a): the 'Determine cache key' run block places expressions directly in the script: `"${{ runner.os }}"`, `"${{ steps.php.outputs.version }}"`, `"${{ inputs.dependency-versions }}"`, `"${{ inputs.composer-options }}"`, `"${{ hashFiles(...) }}"`, `"${{ inputs.custom-cache-key }}"`, `"${{ inputs.custom-cache-suffix }}"` and `"${{ inputs.working-directory }}"`. Fix: route each value through env: and use double-quoted shell variables ($RUNNER_OS for the runner OS).

Locations:

- `action.yml:78`

### script-injection (severity: high)

Rule (a): the 'Install Composer dependencies' run block places expressions directly in the script: `"${{ inputs.dependency-versions }}"`, `"${{ inputs.composer-options }}"`, `"${{ inputs.working-directory }}"`, `"${{ steps.php.outputs.path }}"`, `"${{ steps.composer.outputs.composer_command }}"`, `"${{ steps.composer.outputs.lock }}"`, `"${{ inputs.require-lock-file }}"` and `"${{ inputs.composer-filename }}"`. Fix: route each value through env: and use double-quoted shell variables.

Locations:

- `action.yml:99`

### github-env-injection (severity: high)

bin/cache_key.sh, run by the 'Determine cache key' step, writes `echo "key=${cache_key}" >> "${GITHUB_OUTPUT}"`. cache_key is built from inputs.custom-cache-key, inputs.composer-options, inputs.custom-cache-suffix and inputs.working-directory. make_key only replaces spaces and tabs with dashes, so newlines are kept and nothing strips them before the write (no `printf '%s' ... | tr -d '\n\r'`). A newline in an input can add extra output keys.

Locations:

- `bin/cache_key.sh:61`

### github-env-injection (severity: high)

bin/cache_key.sh writes the restore key to $GITHUB_ENV with a fixed heredoc delimiter: `echo "CACHE_RESTORE_KEY<<EOF"; printf '%s\n' "${uniq_restore_key[@]}"; echo "EOF"` >> "${GITHUB_ENV}". The value comes from inputs (composer-options, working-directory, custom-cache-suffix), and any space in it is turned into a newline. An input containing a word or line equal to `EOF` ends the block early, and everything after it is written as new environment variables (e.g. LD_PRELOAD, BASH_ENV). Fix: generate the delimiter from /dev/urandom or openssl rand on every run.

Locations:

- `bin/cache_key.sh:66`

### github-env-injection (severity: high)

bin/composer_paths.sh, run by the 'Determine Composer paths' step, writes `echo "json=${composer_json}"`, `echo "lock=${composer_lock}"` and `echo "cache-dir=${cache_dir}"` to "${GITHUB_OUTPUT}". composer_json and composer_lock come from inputs.working-directory and inputs.composer-filename. When composer-filename is empty, the filename comes from the inherited COMPOSER env var. Newlines are not stripped before the write.

Locations:

- `bin/composer_paths.sh:70`

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

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 2da05e8..e49fe9b 100644
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
@@ -41,50 +38,75 @@ inputs:
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
+        INPUT_PHP_PATH: ${{ steps.php.outputs.path }}
+        INPUT_COMPOSER_FILENAME: ${{ inputs.composer-filename }}
       run: |
         ${GITHUB_ACTION_PATH}/bin/composer_paths.sh \
           "" \
-          "${{ inputs.working-directory }}" \
-          "${{ steps.php.outputs.path }}" \
-          "${{ inputs.composer-filename }}"
-
+          "$INPUT_WORKING_DIRECTORY" \
+          "$INPUT_PHP_PATH" \
+          "$INPUT_COMPOSER_FILENAME"
     - name: "Determine cache key"
       id: "cache-key"
       if: steps.should-cache.outputs.do-cache == 1
       shell: "bash"
+      env:
+        INPUT_RUNNER_OS: ${{ runner.os }}
+        INPUT_PHP_VERSION: ${{ steps.php.outputs.version }}
+        INPUT_DEPENDENCY_VERSIONS: ${{ inputs.dependency-versions }}
+        INPUT_COMPOSER_OPTIONS: ${{ inputs.composer-options }}
+        INPUT_FILES_HASH: ${{ hashFiles(format('**/{0}.json', inputs.composer-filename), format('**/{0}.lock', inputs.composer-filename)) }}
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
+          "$INPUT_RUNNER_OS" \
+          "$INPUT_PHP_VERSION" \
+          "$INPUT_DEPENDENCY_VERSIONS" \
+          "$INPUT_COMPOSER_OPTIONS" \
+          "$INPUT_FILES_HASH" \
+          "$INPUT_CUSTOM_CACHE_KEY" \
+          "$INPUT_CUSTOM_CACHE_SUFFIX" \
+          "$INPUT_WORKING_DIRECTORY"
     - name: "Cache Composer dependencies"
       if: steps.should-cache.outputs.do-cache == 1
       uses: "actions/cache@0400d5f644dc74513175e3cd8d07132dd4860809" # v4.2.4
@@ -93,16 +115,24 @@ runs:
         key: "${{ steps.cache-key.outputs.key }}"
         restore-keys: |
           ${{ env.CACHE_RES
... (truncated)
```

Locations:

- `action.yml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed bin/cache_key.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/bin/cache_key.sh b/bin/cache_key.sh
index cfc4d8f..c6e3c6b 100755
--- a/bin/cache_key.sh
+++ b/bin/cache_key.sh
@@ -16,7 +16,7 @@ function make_key {
             non_empties+=("${element}")
         fi
     done
-    tr "[:blank:]" "-" <<<"${non_empties[*]}"
+    tr "[:blank:]" "-" <<< "${non_empties[*]}"
 }
 
 runner_os="${1:-}"
@@ -51,19 +51,25 @@ fi
 
 # Remove duplicates.
 # shellcheck disable=SC2207
-uniq_restore_key=($(tr ' ' '\n' <<<"${restore_key[@]}" | awk '!u[$0]++' | tr '\n' ' '))
+uniq_restore_key=($(tr ' ' '\n' <<< "${restore_key[@]}" | awk '!u[$0]++' | tr '\n' ' '))
 
 cache_key="$(make_key "${key[@]}")"
 
 echo "::debug::Cache primary key is '${cache_key}'"
 echo "::debug::Cache restore keys are '$(join_by ", " "${uniq_restore_key[@]}")'"
 
-echo "key=${cache_key}" >> "${GITHUB_OUTPUT}"
+# Sanitize cache_key: strip newlines to prevent GITHUB_OUTPUT injection
+safe_cache_key="$(printf '%s' "${cache_key}" | tr -d '\n\r')"
+echo "key=${safe_cache_key}" >> "${GITHUB_OUTPUT}"
 
 # Use an environment variable to capture the multiline restore key.
 # See: https://docs.github.com/en/actions/learn-github-actions/workflow-commands-for-github-actions#multiline-strings
+# Sanitize each restore key entry by stripping newlines before writing to GITHUB_ENV.
 {
     echo "CACHE_RESTORE_KEY<<EOF"
-    printf '%s\n' "${uniq_restore_key[@]}"
+    for rk in "${uniq_restore_key[@]}"; do
+        printf '%s' "${rk}" | tr -d '\n\r'
+        printf '\n'
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
index b988530..9aeab90 100755
--- a/bin/composer_paths.sh
+++ b/bin/composer_paths.sh
@@ -67,9 +67,10 @@ echo "::debug::Composer cache directory found at '${cache_dir}'"
 echo "::debug::File composer.json found at '${composer_json}'"
 echo "::debug::File composer.lock path computed as '${composer_lock}'"
 echo "::debug::The COMPOSER environment variable is '${COMPOSER}'"
+# Sanitize each output value by stripping newlines to prevent GITHUB_OUTPUT injection.
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

action.yml: in all four run steps, inputs and step outputs are now passed through env: as INPUT_* variables and quoted with double quotes. The runner OS now comes from the built-in $RUNNER_OS. Argument order and count to the bin/*.sh scripts are unchanged, but upstream's stray trailing backslash on the install step's last line is gone. bin/cache_key.sh: newlines are stripped from the cache key before it is written to GITHUB_OUTPUT. The CACHE_RESTORE_KEY heredoc delimiter is now random on every run (from /dev/urandom). The restore-key lines are written as they were, because each line is already a single word with no spaces. bin/composer_paths.sh: newlines and carriage returns are stripped from composer_command, cache-dir, json and lock using bash parameter expansion. That avoids wrapping one command substitution inside another, which would hide a failing command. I haven't run the action, so none of this is tested yet.

