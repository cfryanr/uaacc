#!/usr/bin/env bash

set -eu

for v in 2.1 2.2 2.3 2.4 2.5 2.6; do
    echo "Running tests using Ruby ${v}..."
    $(dirname "$0")/run_tests.sh $v
done

echo 'All tests passed! :)'
