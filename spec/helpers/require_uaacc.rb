# Require the uaacc file in a custom way which avoids having it execute its main method
def require_uaacc
  source_code_to_remove = 'CLI.new.main(ARGV)'.chomp
  uaacc_source_file = File.join(File.dirname(__FILE__), '..', '..', 'uaacc')

  uaacc_code = File.read(uaacc_source_file).rstrip
  raise 'missing expected source code' unless uaacc_code.end_with?(source_code_to_remove)

  eval(uaacc_code.chomp(source_code_to_remove), TOPLEVEL_BINDING)
end
