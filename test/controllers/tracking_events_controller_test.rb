require "test_helper"

class TrackingEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payload = {
      "gfsId" => "54207921",
      "carrierName" => "EVRi",
      "consignmentNumber" => "T01TUA0031692382",
      "parcelNumber" => "T01TUA0031694677",
      "status" => "OUT FOR DELIVERY",
      "text" => "OUT FOR DELIVERY",
      "isDelivered" => false
    }

    @token = ENV["CARRIER_SIGNATURE"]
  end

  test "creates a tracking event" do
    assert_difference -> { TrackingEvent.count }, +1 do
      post tracking_events_path, params: @payload, headers: { "x-gfs-token" => @token }
    end

    assert_response :ok
  end

  test "recognizes differently formatted tracking event statuses" do
    post tracking_events_path, params: @payload, headers: { "x-gfs-token" => @token }
    last_tracking_event = TrackingEvent.last

    assert_equal "out_for_delivery", last_tracking_event.status
  end

  test "unrecognized tracking statuses are stored with an unknown status" do
    post tracking_events_path, params: @payload.merge("status" => "data only"), headers: { "x-gfs-token" => @token }
    last_tracking_event = TrackingEvent.last

    assert_equal "unknown", last_tracking_event.status
  end

  test "the original tracking payload is stored on the tracking event" do
    post tracking_events_path, params: @payload, headers: { "x-gfs-token" => @token }
    last_tracking_event = TrackingEvent.last

    assert_equal normalize_payload(@payload), normalize_payload(last_tracking_event.payload)
  end

  test "unauthorized requests still see a head 200 OK" do
    assert_no_difference -> { TrackingEvent.count } do
      post tracking_events_path, params: @payload, headers: { "x-gfs-token" => "random-token" }
    end

    assert_response :ok
  end

  test "requests missing the authorization header still see a head 200 OK" do
    assert_no_difference -> { TrackingEvent.count } do
      post tracking_events_path, params: @payload
    end

    assert_response :ok
  end

  private

  def normalize_payload(hash)
    hash.transform_values do |value|
      case value
      when "true" then true
      when "false" then false
      else value
      end
    end
  end
end
