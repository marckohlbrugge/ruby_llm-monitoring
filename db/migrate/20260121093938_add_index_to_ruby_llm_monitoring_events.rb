class AddIndexToRubyLLMMonitoringEvents < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    return if index_exists?(:ruby_llm_monitoring_events, :created_at)

    options = {name: "index_ruby_llm_monitoring_events_on_created_at"}
    options[:algorithm] = :concurrently if postgresql?

    add_index :ruby_llm_monitoring_events, :created_at, **options
  end

  private

  def postgresql?
    connection.adapter_name.downcase.include?("postgres")
  end
end
