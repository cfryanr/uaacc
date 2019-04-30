#!/usr/bin/env bash

set -eu

cd /uaacc/spec

echo "Running with $(ruby -v)"
ruby_major_version=$(ruby -v | cut -f 2 -d ' ' | cut -f 1 -d '.')
ruby_minor_version=$(ruby -v | cut -f 2 -d ' ' | cut -f 2 -d '.')

if [[ $ruby_major_version != 2 ]]; then
    echo "Error: Need Ruby version 2"
    exit 1
fi

if [[ $ruby_minor_version < 3 ]]; then

    # Newer versions of bundler require Ruby 2.3+
    gem install bundler -v 1.17.3

    TMP_GEM_DIR=/tmp/gems
    mkdir -p $TMP_GEM_DIR
    cp Gemfile $TMP_GEM_DIR/Gemfile
    head -$(expr $(cat Gemfile.lock| wc -l) - 2) Gemfile.lock > $TMP_GEM_DIR/Gemfile.lock

    bundle --gemfile $TMP_GEM_DIR/Gemfile
    BUNDLE_GEMFILE=$TMP_GEM_DIR/Gemfile bundle exec rspec .

else

    gem install bundler

    bundle
    bundle exec rspec .

fi
