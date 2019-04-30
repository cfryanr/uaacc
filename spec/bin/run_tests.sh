#!/usr/bin/env bash

set -eu

# default to 2.1, which is the minimum version that works
RUBY_VERSION=${1:-2.1}

docker run -it -v $HOME/workspace/uaacc:/uaacc ruby:$RUBY_VERSION \
    uaacc/spec/bin/run_tests_in_docker_container.sh
