class UaaccExited < Exception
end

class System
  class << self
    attr_reader :stdout, :stderr, :status
  end

  def self.puts_stdout(msg)
    @stdout << msg.to_s
    @stdout << "\n"
  end

  def self.puts_stderr(msg)
    @stderr << msg.to_s
    @stderr << "\n"
  end

  def self.do_exit(code)
    @status = code
    # raise to end the invocation of the app's code, simulating exit without actually exiting
    raise UaaccExited, "uaacc exited with code #{code}"
  end

  def self.read_file(path)
    raise "Unexpected read_file: #{path}" unless path == Config::FILE
    @conf_file
  end

  def self.write_file(path, content)
    raise "Unexpected write_file: #{path}" unless path == Config::FILE
    @conf_file = content
  end

  def self.set_config_file_content(config)
    @conf_file = HashUtils.stringify(config).to_yaml
  end

  def self.config_file_contents
    HashUtils.symbolize(YAML.load(@config_file == '' ? '{}' : @conf_file))
  end

  def self.reset
    @stdout = ''
    @stderr = ''
    @status = nil
  end

  def self.reset_files
    @conf_file = ''
  end
end
