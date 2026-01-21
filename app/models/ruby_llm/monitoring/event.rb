module RubyLLM::Monitoring
  class Event < ApplicationRecord
    include Alertable

    before_validation :set_cost

    # Accessor methods for payload fields (replaces virtual columns)
    def provider
      payload&.dig("provider")
    end

    def model
      payload&.dig("model")
    end

    def input_tokens
      payload&.dig("input_tokens")
    end

    def output_tokens
      payload&.dig("output_tokens")
    end

    def exception_class
      payload&.dig("exception", 0)
    end

    def exception_message
      payload&.dig("exception", 1)
    end

    private

    def set_cost
      model, provider = RubyLLM.models.resolve payload["model"], provider: payload["provider"]

      self.cost = if provider.local? || [payload["input_tokens"], payload["output_tokens"]].all?(nil)
        0.0
      else
        input_cost = payload["input_tokens"] / 1_000_000.0 * model.input_price_per_million
        output_cost = payload["output_tokens"] / 1_000_000.0 * model.output_price_per_million

        input_cost + output_cost
      end
    end
  end
end
