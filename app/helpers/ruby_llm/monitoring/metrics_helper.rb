module RubyLLM::Monitoring
  module MetricsHelper
    def resolution_options
      { "1 minute" => 1, "10 minutes" => 10, "1 hour" => 60, "1 day" => 1440 }
    end
  end
end
