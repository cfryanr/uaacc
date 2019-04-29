require 'open3'

require_relative 'helpers/spec_helper'
require_relative 'helpers/custom_matchers'
require_relative 'helpers/uaacc_result'

RSpec.describe 'uaacc' do
  def uaacc(args)
    uaacc_path = File.join(File.dirname(__FILE__), '..', 'uaacc')
    stdout, stderr, status = Open3.capture3("#{uaacc_path} #{args}")
    UaaccResult.new(stdout, stderr, status.exitstatus)
  end

  let(:expected_usage_help_text) do
    <<~USAGE
      Usage:
      Global options: [{-h|--help}]
        uaacc target [url]
        uaacc login <username> <password>
        uaacc logout
        uaacc get <path> [<query1=value1> ... <queryN=valueN>] [--html|--json]
        uaacc post TBD
        uaacc put TBD
        uaacc delete TBD
        uaacc expect {status|body} [not] {equals|contains|starts_with|ends_with|matches} <expected_text>
        uaacc expect header <header_name> [not] {equals|contains|starts_with|ends_with|matches} <expected_text>
        uaacc expect body_json_path <json_path> [not] {equals|contains|starts_with|ends_with|matches} <expected_text>
        uaacc print body_json_path <path>
    USAGE
  end

  let(:config_file) { File.join(ENV['HOME'], '.uaacc') }

  before do
    File.delete(config_file) if File.exist?(config_file)
  end

  describe 'help message' do
    it 'prints a help message when invoked with no arguments' do
      expect(uaacc '').to be_error_with_stderr_and_status(expected_usage_help_text, 0)
    end

    it 'prints a help message when invoked with --help, even if other arguments are illegal' do
      ['--help', '-h'].each do |help_option|
        expect(uaacc "foo #{help_option} bar --anything").to be_error_with_stderr_and_status(expected_usage_help_text, 0)
      end
    end

    it 'prints an error with help message when an illegal subcommand is used' do
      expect(uaacc 'foo').to be_error_with_stderr_and_status("ERROR: Unrecognized subcommand\n\n#{expected_usage_help_text}", 1)
    end
  end

  describe 'target' do
    it 'errors with help message when too many arguments are given' do
      expect(uaacc 'target foo bar').to be_error_with_stderr_and_status("ERROR: Wrong number of arguments to \"target\" subcommand\n\n#{expected_usage_help_text}", 1)
    end

    it 'saves the provided target and prints the current target when no arguments are given' do
      expect(uaacc 'target').to be_error_with_stderr_and_status("ERROR: No target set\n", 2)
      expect(uaacc 'target http://foo').to be_quiet_success
      expect(uaacc 'target').to be_successful_with_stdout("http://foo\n")
    end

    it 'allows https targets' do
      expect(uaacc 'target https://foo').to be_quiet_success
      expect(uaacc 'target').to be_successful_with_stdout("https://foo\n")
    end

    it 'allows a path in the target' do
      expect(uaacc 'target https://foo.com/uaa').to be_quiet_success
      expect(uaacc 'target').to be_successful_with_stdout("https://foo.com/uaa\n")
    end

    it 'removes trailing slashes from the target' do
      expect(uaacc "target http://foo/").to be_quiet_success
      expect(uaacc 'target').to be_successful_with_stdout("http://foo\n")

      expect(uaacc "target http://foo.com/path///").to be_quiet_success
      expect(uaacc 'target').to be_successful_with_stdout("http://foo.com/path\n")
    end

    it 'errors when the target is invalid' do
      ['foo', 'ws://foo'].each do |target|
        expect(uaacc "target #{target}").to be_error_with_stderr_and_status("ERROR: invalid target scheme\n", 2)
      end
      expect(uaacc 'target http://foo#fragment').to be_error_with_stderr_and_status("ERROR: target should not have fragment\n", 2)
      expect(uaacc 'target https://foo?a=b').to be_error_with_stderr_and_status("ERROR: target should not have query params\n", 2)
    end
  end
end

#uaac client add myclient --name myclient \
#  --scope uaa.user --authorized_grant_types authorization_code \
#  --authorities uaa.user --autoapprove uaa.user --secret pass \
#  --redirect_uri http://example.com

#uaacc login admin $UAA_ADMIN_USER_PASSWORD --debug
#uaacc get oauth/authorize response_type=code client_id=myclient scope=uaa.user redirect_uri=http://example.com/path --debug
#uaacc get info --debug --json
#uaacc get info --debug --html
#cat $HOME/.uaacc

