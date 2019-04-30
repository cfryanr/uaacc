class UaaccExited < Exception
end

class System
  class << self
    attr_reader :stdout, :stderr, :status, :conf_file
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

  def self.reset
    @stdout = ''
    @stderr = ''
    @status = nil
  end

  def self.reset_files
    @conf_file = ''
  end
end
