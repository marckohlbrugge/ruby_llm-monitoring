module RubyLLM::Monitoring
  class MetricsQuery
    DEFAULT_DIMENSIONS = %i[provider model].freeze

    Result = Data.define(:metrics, :totals, :totals_by_dimension)
    Totals = Data.define(:requests, :cost, :avg_response_time, :error_rate)
    DimensionTotal = Data.define(:dimensions, :requests, :cost, :avg_response_time) do
      def method_missing(name, ...)
        dimensions.key?(name) ? dimensions[name] : super
      end

      def respond_to_missing?(name, include_private = false)
        dimensions.key?(name) || super
      end
    end

    attr_reader :time_range, :resolution, :dimensions

    def initialize(time_range:, resolution:, dimensions: DEFAULT_DIMENSIONS)
      @time_range = time_range
      @resolution = resolution
      @dimensions = dimensions
    end

    def result
      @result ||= build_result
    end

    private

    def build_result
      metrics_data = { throughput: {}, cost: {}, response_time: {}, errors: {} }
      totals_by_key = Hash.new { |h, k| h[k] = { requests: 0, cost: 0.0, duration_weighted: 0.0, errors: 0 } }

      fetch_aggregated_data.each do |row|
        key = dimensions.map { |d| row[d.to_s] }
        ts = row["time_bucket"].to_i * 1000
        count = row["request_count"].to_i
        cost = row["total_cost"].to_f
        avg_duration = row["avg_duration"]&.to_f
        error_count = row["error_count"].to_i

        metrics_data[:throughput][key] ||= []
        metrics_data[:throughput][key] << [ ts, count ]

        metrics_data[:cost][key] ||= []
        metrics_data[:cost][key] << [ ts, cost ]

        metrics_data[:response_time][key] ||= []
        metrics_data[:response_time][key] << [ ts, avg_duration || 0 ]

        metrics_data[:errors][key] ||= []
        metrics_data[:errors][key] << [ ts, error_count ]

        totals_by_key[key][:requests] += count
        totals_by_key[key][:cost] += cost
        totals_by_key[key][:duration_weighted] += (avg_duration || 0) * count
        totals_by_key[key][:errors] += error_count
      end

      total_requests = totals_by_key.values.sum { |v| v[:requests] }
      total_errors = totals_by_key.values.sum { |v| v[:errors] }

      Result.new(
        metrics: [
          build_metric_series(title: "Throughput", data: metrics_data[:throughput]),
          build_metric_series(title: "Cost", data: metrics_data[:cost], unit: "money"),
          build_metric_series(title: "Response time", data: metrics_data[:response_time], unit: "ms"),
          build_metric_series(title: "Errors", data: metrics_data[:errors], unit: "number")
        ],
        totals_by_dimension: totals_by_key.map do |key, data|
          DimensionTotal.new(
            dimensions: dimensions.zip(key).to_h,
            requests: data[:requests],
            cost: data[:cost],
            avg_response_time: data[:requests].positive? ? data[:duration_weighted] / data[:requests] : nil
          )
        end,
        totals: Totals.new(
          requests: total_requests,
          cost: totals_by_key.values.sum { |v| v[:cost] },
          avg_response_time: total_requests.positive? ? totals_by_key.values.sum { |v| v[:duration_weighted] } / total_requests : nil,
          error_rate: total_requests.positive? ? (total_errors.to_f / total_requests * 100).round(1) : 0
        )
      )
    end

    def fetch_aggregated_data
      bucket_seconds = resolution.to_i
      time_bucket = time_bucket_sql(bucket_seconds)
      dimension_columns = dimensions.join(", ")

      sql = <<~SQL.squish
        SELECT
          #{dimension_columns},
          #{time_bucket} as time_bucket,
          COUNT(*) as request_count,
          COALESCE(SUM(cost), 0) as total_cost,
          AVG(duration) as avg_duration,
          SUM(CASE WHEN exception_class IS NOT NULL THEN 1 ELSE 0 END) as error_count
        FROM #{Event.table_name}
        WHERE created_at >= :start_time
          AND (:end_time IS NULL OR created_at <= :end_time)
        GROUP BY #{dimension_columns}, time_bucket
        ORDER BY time_bucket
      SQL

      Event.connection.select_all(
        Event.sanitize_sql_array([ sql, start_time: time_range.begin, end_time: time_range.end ])
      )
    end

    def time_bucket_sql(bucket_seconds)
      case Event.connection.adapter_name.downcase
      when "postgresql"
        "EXTRACT(EPOCH FROM date_trunc('second', created_at))::bigint / #{bucket_seconds} * #{bucket_seconds}"
      when "mysql2"
        "UNIX_TIMESTAMP(created_at) DIV #{bucket_seconds} * #{bucket_seconds}"
      else # sqlite
        "CAST(strftime('%s', created_at) AS INTEGER) / #{bucket_seconds} * #{bucket_seconds}"
      end
    end

    def build_metric_series(title:, data:, unit: nil)
      {
        title: title,
        unit: unit,
        series: data.map { |k, v| { name: k.join("/"), data: v } }
      }.compact
    end
  end
end
