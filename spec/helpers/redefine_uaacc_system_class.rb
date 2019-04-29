# Redefine the puts and exit methods used by uaacc to make its behavior observable
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
    raise "uaacc exited #{code}"
  end

  def self.reset
    @stdout = ''
    @stderr = ''
  end
end
