# uaacc: The uaac Companion CLI

This is a work in progress. Stay tuned for an initial release after some more work has been done.

## Installing

`uaacc` is a simple Ruby script which does not depend on any gems, so it is easy to install on any UNIX-like system.

```bash
sudo curl -fLo /usr/local/bin/uaacc https://raw.githubusercontent.com/cfryanr/uaacc/master/uaacc && sudo chmod 755 /usr/local/bin/uaacc
```

### Dependencies

`uaacc` depends on having Ruby installed. You probably already have Ruby installed.
You don't need any particular version of Ruby, as long as it's not a super old version.
Ruby 2.1 or newer should work. You can check your Ruby version with `ruby -v`.

[Ruby can be installed easily](https://www.ruby-lang.org/en/documentation/installation/#package-management-systems)
using your system's package manager.

Some functionality of `uaacc` assumes that you have the [uaac](https://github.com/cloudfoundry/cf-uaac) and
[bosh](https://github.com/cloudfoundry/bosh-cli) CLI tools installed and available on your path.
You can use most of the functionality without these dependencies, but will get errors when using certain subcommands
or options.

## Contributing

Not yet. Until the first release, create a github issue with your feedback and suggestions.

### Running Tests

```bash
cd spec
bundle
bundle exec rspec .
```

Or run the tests in docker using `spec/bin/run_tests.sh <ruby_version>`.
