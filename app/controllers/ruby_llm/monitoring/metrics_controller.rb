module RubyLLM::Monitoring
  class MetricsController < ApplicationController
    before_action :set_resolution
    before_action :set_time_range

    def index
      result = MetricsQuery.new(time_range: @time_range, resolution: @resolution).result

      @metrics = result.metrics
      @totals = result.totals
      @totals_by_dimension = result.totals_by_dimension
    end

    private

    def filter_param
      {
        filter: {
          created_at_start: @created_at_start,
          created_at_end: @created_at_end,
          resolution: @resolution
        }
      }.compact
    end

    def set_resolution
      @resolution = params.dig(:filter, :resolution).try(:to_i).try(:minutes) || 1.minute
    end

    def set_time_range
      @created_at_start = params.dig(:filter, :created_at_start).try(:in_time_zone) || 2.hours.ago
      @created_at_end = params.dig(:filter, :created_at_end).try(:in_time_zone)

      @time_range = @created_at_start..@created_at_end
    end
  end
end
