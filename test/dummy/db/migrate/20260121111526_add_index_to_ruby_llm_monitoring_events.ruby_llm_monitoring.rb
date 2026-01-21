# This migration comes from ruby_llm_monitoring (originally 20260121093938)
class AddIndexToRubyLLMMonitoringEvents < ActiveRecord::Migration[8.1]
  def change
    add_index :ruby_llm_monitoring_events, :created_at
  end
end
