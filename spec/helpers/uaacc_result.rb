class UaaccResult
  attr_reader :stdout, :stderr, :status

  def initialize(stdout, stderr, status)
    @stdout = stdout
    @stderr = stderr
    @status = status
  end

  def successful?
    status == 0
  end

  def has_stdout?
    !stdout.empty?
  end

  def has_stderr?
    !stderr.empty?
  end
end
