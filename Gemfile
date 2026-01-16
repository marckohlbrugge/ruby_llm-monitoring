source "https://rubygems.org"

# Specify your gem's dependencies in ruby_llm-monitoring.gemspec.
gemspec

rails_version = ENV.fetch("RAILS_VERSION", "8.1.0")

gem "rails", "~> #{rails_version}"

gem "puma"

if rails_version.start_with?("7.0")
  gem "sqlite3", "~> 1.7"
else
  gem "sqlite3", ">= 2.9"
end

gem "propshaft"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Test dependencies
unless rails_version.start_with?("8")
  gem "minitest", "< 6.0"
end
gem "vcr"
gem "webmock"

# Start debugger with binding.b [https://github.com/ruby/debug]
gem "debug", ">= 1.0.0"

# Make sure we're running against the latest ruby_llm-instrumentation
gem "ruby_llm-instrumentation", github: "sinaptia/ruby_llm-instrumentation"
