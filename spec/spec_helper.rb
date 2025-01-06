require File.expand_path('../../config/environment', __FILE__)
require "rspec/rails"

# This file is used for general RSpec configurations.

# See https://relishapp.com/rspec/rspec-core/docs/configuration

# This file is automatically required when RSpec is invoked with a `spec` directory.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # Use the `expect` syntax rather than `should` syntax.
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure the mock framework (e.g., rspec-mocks or any other mock framework).
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure backtrace cleaner to make the output more readable.
  config.backtrace_exclusion_patterns = [/gems/]

  # Configure the output formatter (optional).
  # Use :documentation for more descriptive output, or :progress for a compact form.
  config.formatter = :documentation  # or :progress

  # Set the default language for the test case descriptions (optional).
  config.default_formatter = 'doc'

  # Enable the colorized output (helps in terminal).
  config.color = true

  # Run only the tests that have changed (useful for continuous integration).
  # config.filter_run_when_matching :focus

  # Run all tests, even if some are pending (optional).
  # config.run_all_when_everything_filtered = true
end
