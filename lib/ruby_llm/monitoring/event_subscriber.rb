module RubyLLM
  module Monitoring
    class EventSubscriber
      def call(event)
        Event.create(
          allocations: event.allocations,
          cpu_time: event.cpu_time,
          duration: event.duration,
          end: event.end,
          gc_time: event.try(:gc_time),
          idle_time: event.idle_time,
          name: event.name,
          payload: event.payload,
          time: event.time,
          transaction_id: event.transaction_id
        )
      end
    end
  end
end
