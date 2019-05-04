require 'vcr'
require_relative 'helpers/rspec_config'
require_relative 'helpers/vcr_config'
require_relative 'helpers/custom_matchers'
require_relative 'helpers/uaacc_result'
load '../uaacc'
require_relative 'helpers/redefine_uaacc_system_class'

RSpec.describe 'uaacc' do

  def uaacc(args)
    System.reset

    begin
      CLI.new.main(args.split(' '))
      raise 'Expected uaacc to call exit, but it did not'
    rescue UaaccExited
    end

    UaaccResult.new(System.stdout, System.stderr, System.status)
  end

  let(:expected_usage_help_text) do
    usage = <<-USAGE
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
    lines = usage.split("\n")
    indent = lines.first.index('Usage')
    lines.map { |line| line[indent..-1] }.join("\n") + "\n"
  end

  before do
    System.reset_files
  end

  describe 'the source code' do
    let(:source) { File.read('../uaacc').rstrip }

    it 'should end with an invocation of main which only runs when the script is invoked directly' do
      expect(source).to end_with('CLI.new.main(ARGV) if __FILE__ == $0')
    end
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

  describe 'login' do
    it 'errors with help message when too many or too few arguments are given' do
      expect(uaacc 'login 1 2 3').to be_error_with_stderr_and_status("ERROR: Wrong number of arguments to \"login\" subcommand\n\n#{expected_usage_help_text}", 1)
      expect(uaacc 'login 1').to be_error_with_stderr_and_status("ERROR: Wrong number of arguments to \"login\" subcommand\n\n#{expected_usage_help_text}", 1)
    end

    context 'when there is a target in the state file', :vcr do
      before do
        System.set_config_file_content(target: 'http://localhost:8080/uaa')
      end

      context 'when the username and password are correct' do
        it 'logs in and saves the session cookie' do
          expect(uaacc "login marissa koala").to be_quiet_success

          saved_cookies = System.config_file_contents[:cookies]
          expect(saved_cookies).to have_key(:JSESSIONID)
          expect(saved_cookies[:JSESSIONID]).to match(/^[A-Z0-9]{32}$/)
        end
      end

      context 'when the username and password are not correct' do
        it 'errors' do
          expect(uaacc 'login marissa wrong').to be_error_with_stderr_and_status("ERROR: Login failed. Wrong username or password?\n", 2)
        end
      end

      context 'when there is also a session cookie in the state file' do
        before do
          System.set_config_file_content(
              target: 'http://localhost:8080/uaa',
              cookies: {JSESSIONID: 'should_not_use_this_session_id'}
          )
        end

        it 'does not use the old session id in any requests' do |example|
          expect(uaacc "login marissa koala").to be_quiet_success
          cassette = example.description.gsub(' ', '_') + '.yml'
          expect(File.read(Dir.glob("vcr_cassettes/**/#{cassette}").first)).not_to include('should_not_use_this_session_id')
        end
      end
    end

    context 'when there is no target in the state file' do
      it 'errors' do
        expect(uaacc 'login u p').to be_error_with_stderr_and_status("ERROR: No target set\n", 2)
      end
    end
  end

  describe 'logout' do
    it 'errors with help message when too many arguments are given' do
      expect(uaacc 'logout anything').to be_error_with_stderr_and_status("ERROR: Wrong number of arguments to \"logout\" subcommand\n\n#{expected_usage_help_text}", 1)
    end

    context 'when there are no cookies in the state file' do
      it 'succeeds' do
        expect(uaacc 'logout').to be_quiet_success
      end
    end

    context 'when there are cookies in the state file' do
      before do
        System.set_config_file_content(
            cookies: {
                cookie1: 1,
                cookie2: 2
            },
            target: 'the_target'
        )
      end

      it 'succeeds and deletes all cookies and leaves other state values' do
        expect(uaacc 'logout').to be_quiet_success
        expect(System.config_file_contents).to eq(cookies: {}, target: 'the_target')
      end
    end
  end

  describe 'get' do
    it 'errors with help message when too few arguments are given' do
      expect(uaacc 'get').to be_error_with_stderr_and_status("ERROR: Wrong number of arguments to \"get\" subcommand\n\n#{expected_usage_help_text}", 1)
    end

    context 'when there is no target set' do
      it 'errors' do
        expect(uaacc 'get anything').to be_error_with_stderr_and_status("ERROR: No target set\n", 2)
      end
    end

    context 'when the target is set', :vcr do
      before do
        uaacc 'target http://localhost:8080/uaa'
      end

      it 'makes a request to the given path and stores the response' do
        expect(System.config_file_contents[:response]).to be_nil
        expect(uaacc 'get /info').to be_quiet_success

        expect(System.config_file_contents[:response][:code]).to eq(200)
        expect(System.config_file_contents[:response][:body]).to include('{"app":{"version":')
        expect(System.config_file_contents[:response][:headers]).to include(:'cache-control' => ['no-store'])
      end
    end
  end
end
