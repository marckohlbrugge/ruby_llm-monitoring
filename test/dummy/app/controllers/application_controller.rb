class ApplicationController < ActionController::Base
  if Rails.gem_version >= Gem::Version.new("7.2")
    allow_browser versions: :modern
  end
end
