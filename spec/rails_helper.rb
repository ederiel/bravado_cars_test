ENV['RAILS_ENV'] ||= 'test'

require "spec_helper"

RSpec.configure do |config|
  config.fixture_path = "#{Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
end
