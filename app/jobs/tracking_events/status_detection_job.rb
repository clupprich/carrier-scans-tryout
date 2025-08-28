module TrackingEvents
  class StatusDetectionJob < ApplicationJob
    queue_as :within_1_hour

    def perform(tracking_event)
      tracking_event.detect_status
    end
  end
end
