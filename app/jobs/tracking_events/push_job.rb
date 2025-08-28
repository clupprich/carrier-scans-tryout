module TrackingEvents
  class PushJob < ApplicationJob
    def perform(tracking_event)
      tracking_event.push!
    end
  end
end
