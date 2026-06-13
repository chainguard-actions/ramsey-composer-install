#!/usr/bin/env bash

php_path="${1:-$(which php)}"

# Test PHP command.
function test_php {
    $php_path -v > /dev/null 2>&1
}

if ! test_php; then
    echo "::error title=PHP Not Found::Unable to find PHP at '${php_path}'"
    exit 1
fi

php_version=$($php_path -r 'echo phpversion();')

echo "::debug::PHP path is '${php_path}'"
echo "::debug::PHP version is '${php_version}'"
safe_php_path="$(printf '%s' "${php_path}" | tr -d '\n\r')"
safe_php_version="$(printf '%s' "${php_version}" | tr -d '\n\r')"
echo "path=${safe_php_path}" >> "${GITHUB_OUTPUT}"
echo "version=${safe_php_version}" >> "${GITHUB_OUTPUT}"
