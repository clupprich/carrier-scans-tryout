class TrackingEvent
  class StatusDetection
    def initialize(tracking_event)
      @tracking_event = tracking_event
    end

    # @return [String]
    def outcome
      return status unless tracking_event.unknown?

      detect_by_status || detect_by_message || "other"
    end

    private

    attr_reader :tracking_event
    delegate :message, :payload, :status, to: :tracking_event

    # The `#detect_by_status` tries to detect the status of a tracking event by looking at
    # differently named status codes. We're mimicking the tracking event status codes from
    # Fulfil and GFS uses sometimes slightly different status codes.
    #
    # @return [String, nil]
    def detect_by_status
      tracking_status = TrackingEvent.normalize_value_for(:status, payload["status"])

      case tracking_status
      when "awaiting_collection"
        "waiting"
      when TrackingEvent.statuses.include?(tracking_status)
        tracking_status
      else
        nil
      end
    end

    # The `#detect_by_message` tries to detect the status of a tracking event by looking at
    # the normalized tracking event status message. We have a pre-defined list of matching
    # messages that we're comparing them with.
    #
    # @return [String, nil]
    def detect_by_message
      normalized_message = TrackingEvent.normalize_value_for(:status, message)
      status_messages_by_status = Rails.application.config_for(:tracking_events_status_texts)

      status_by_message = status_messages_by_status.find do |status_text|
        status_text[:messages].find do |status_text|
          TrackingEvent.normalize_value_for(:status, status_text) == normalized_message
        end
      end

      status_by_message[:status] if status_by_message.present?
    end
  end
end
