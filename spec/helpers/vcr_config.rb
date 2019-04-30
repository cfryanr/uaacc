VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {
      :record => :once, # or :new_episodes
      :match_requests_on => [:method, :uri, :body, :headers]
  }
end
