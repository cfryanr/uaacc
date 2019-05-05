RSpec::Matchers.define :be_quiet_success do |_expected|
  match do |actual|
    !actual.has_stdout? && !actual.has_stderr? && actual.successful?
  end

  failure_message do |actual|
    errors(actual, false)
  end

  failure_message_when_negated do |actual|
    errors(actual, true)
  end

  def errors(actual, invert)
    msg = "Expected #{invert ? 'not ' : ''}to be a quiet success\nbut "
    errors = []
    errors << ["actual status was #{actual.status.inspect}", actual.successful?]
    errors << ["actual stdout was #{actual.stdout.inspect}", !actual.has_stdout?]
    errors << ["actual stderr was #{actual.stderr.inspect}", !actual.has_stderr?]
    msg + errors.select { |e| e[1] == invert }.map(&:first).join(', ')
  end
end

RSpec::Matchers.define :be_successful_with_stdout do |expected_stdout|
  match do |actual|
    actual.stdout == expected_stdout && !actual.has_stderr? && actual.successful?
  end

  failure_message do |actual|
    errors(actual, expected_stdout, false)
  end

  failure_message_when_negated do |actual|
    errors(actual, expected_stdout, true)
  end

  def errors(actual, expected_stdout, invert)
    msg = "Expected #{invert ? 'not ' : ''}to be a success with stdout #{expected_stdout.inspect}\nbut "
    errors = []
    errors << ["actual status was #{actual.status.inspect}", actual.successful?]
    errors << ["actual stdout was #{actual.stdout.inspect}", actual.stdout == expected_stdout]
    errors << ["actual stderr was #{actual.stderr.inspect}", !actual.has_stderr?]
    msg + errors.select { |e| e[1] == invert }.map(&:first).join(', ')
  end
end

RSpec::Matchers.define :be_successful_with_stdout_and_stderr do |expected_stdout, expected_stderr|
  match do |actual|
    actual.stdout == expected_stdout && actual.stderr == expected_stderr && actual.successful?
  end

  failure_message do |actual|
    errors(actual, expected_stdout, expected_stderr, false)
  end

  failure_message_when_negated do |actual|
    errors(actual, expected_stdout, expected_stderr, true)
  end

  def errors(actual, expected_stdout, expected_stderr, invert)
    msg = "Expected #{invert ? 'not ' : ''}to be a success with stdout #{expected_stdout.inspect} and stderr #{expected_stderr.inspect}\nbut "
    errors = []
    errors << ["actual status was #{actual.status.inspect}", actual.successful?]
    errors << ["actual stdout was #{actual.stdout.inspect}", actual.stdout == expected_stdout]
    errors << ["actual stderr was #{actual.stderr.inspect}", actual.stderr == expected_stderr]
    msg + errors.select { |e| e[1] == invert }.map(&:first).join(', ')
  end
end

RSpec::Matchers.define :be_error_with_stderr_and_status do |expected_stderr, expected_status|
  match do |actual|
    !actual.has_stdout? && actual.stderr == expected_stderr && actual.status == expected_status
  end

  failure_message do |actual|
    errors(actual, expected_stderr, expected_status, false)
  end

  failure_message_when_negated do |actual|
    errors(actual, expected_stderr, expected_status, true)
  end

  def errors(actual, expected_stderr, expected_status, invert)
    msg = "Expected #{invert ? 'not ' : ''}to be an error with stderr #{expected_stderr.inspect} and status #{expected_status}\nbut "
    errors = []
    errors << ["actual status was #{actual.status.inspect}", actual.status == expected_status]
    errors << ["actual stdout was #{actual.stdout.inspect}", !actual.has_stdout?]
    errors << ["actual stderr was #{actual.stderr.inspect}", actual.stderr == expected_stderr]
    msg + errors.select { |e| e[1] == invert }.map(&:first).join(', ')
  end
end
