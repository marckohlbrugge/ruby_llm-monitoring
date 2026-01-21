class CreateRubyLLMMonitoringEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :ruby_llm_monitoring_events do |t|
      t.integer :allocations
      t.float :cost
      t.float :cpu_time
      t.float :duration
      t.float :end
      t.float :gc_time
      t.float :idle_time
      t.string :name
      t.json :payload
      t.float :time
      t.string :transaction_id

      t.timestamps
    end
  end
end
