class OptimizePayloadColumnForPostgresql < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    return unless postgresql?

    # Convert json to jsonb for faster extraction and indexing
    # This requires a table rewrite but preserves all data
    execute "ALTER TABLE ruby_llm_monitoring_events ALTER COLUMN payload TYPE jsonb USING payload::jsonb"

    # Add expression index on common grouping dimensions
    add_index :ruby_llm_monitoring_events,
      "(payload->>'provider'), (payload->>'model')",
      name: "index_ruby_llm_monitoring_events_on_payload_dimensions",
      algorithm: :concurrently
  end

  def down
    return unless postgresql?

    remove_index :ruby_llm_monitoring_events, name: "index_ruby_llm_monitoring_events_on_payload_dimensions", if_exists: true
    execute "ALTER TABLE ruby_llm_monitoring_events ALTER COLUMN payload TYPE json USING payload::json"
  end

  private

  def postgresql?
    connection.adapter_name.downcase.include?("postgres")
  end
end
