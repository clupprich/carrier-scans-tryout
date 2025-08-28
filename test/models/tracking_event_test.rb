require "test_helper"

class TrackingEventTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "stores the normalized result as the status" do
    to_normalize_tracking_event = tracking_events(:to_normalize)

    assert_changes -> { to_normalize_tracking_event.reload.status }, to: "waiting" do
      to_normalize_tracking_event.detect_status
    end
  end

  test "schedules a tracking event with an unknown to be normalized after creation" do
    assert_enqueued_jobs 1, only: TrackingEvents::StatusDetectionJob do
      TrackingEvent.create!(source_id: SecureRandom.uuid, carrier: "FedEx", message: "Something unknown", tracking_number: SecureRandom.hex(16))
    end
  end

  test "does not attempt to normalize a tracking event with a known status in a background job" do
    assert_no_enqueued_jobs only: TrackingEvents::StatusDetectionJob do
      TrackingEvent.create!(status: TrackingEvent.statuses.except(:unknown).keys.sample, source_id: SecureRandom.uuid, carrier: "FedEx", message: "Something unknown", tracking_number: SecureRandom.hex(16))
    end
  end

  test "schedules a tracking event with a known status to be pushed after creation" do
    assert_enqueued_jobs 1, only: TrackingEvents::PushJob do
      TrackingEvent.create!(status: TrackingEvent.statuses.except(:unknown).keys.sample, source_id: SecureRandom.uuid, carrier: "FedEx", message: "Something unknown", tracking_number: SecureRandom.hex(16))
    end
  end

  test "schedules a tracking event transitioning to a known status to be pushed" do
    tracking_event = tracking_events(:to_normalize)

    assert_enqueued_jobs 1, only: TrackingEvents::PushJob do
      tracking_event.delivered!
    end
  end

  test "leaves a note on the customer shipment when pushing the tracking event to Fulfil" do
    tracking_event = tracking_events(:pushable)
    customer_shipment_id = rand(1..100)
    note_id = rand(101..200)

    stub_fulfil_request(:put, model: "stock.shipment.out", response: [ { id: customer_shipment_id, number: "CS#{customer_shipment_id}" } ])
    stub_fulfil_request(:post, model: "ir.note", response: [ { id: note_id, rec_name: note_id.to_s } ])

    tracking_event.push!

    assert_requested :post, /ir\.note/ do |request|
      assert_equal "stock.shipment.out,#{customer_shipment_id}", JSON.parse(request.body).first["resource"]
    end
  end

  test "marks a tracking event as pushed" do
    tracking_event = tracking_events(:pushable)

    stub_fulfil_request(:put, model: "stock.shipment.out", response: [ { id: rand(1..100), number: "CS#{rand(1..100)}" } ])
    stub_fulfil_request(:post, model: "ir.note", response: [ { id: rand(1..100), rec_name: rand(1..100).to_s } ])

    assert_changes -> { tracking_event.reload.pushed? }, from: false, to: true do
      tracking_event.push!
    end
  end

  test "can skip creating a note on the customer shipment" do
    tracking_event = tracking_events(:pushable)
    tracking_event.push!(include_on_timeline: false)

    assert_not_requested :post, /ir\.note/
  end

  test "raises an UnpushableError when trying to push an tracking event that can't be pushed yet" do
    assert_raises TrackingEvent::UnpushableError, "can't push to Fulfil because the status is not normalized yet" do
      tracking_events(:to_normalize).push!
    end

    assert_raises TrackingEvent::UnpushableError, "can't push to Fulfil because it is already pushed" do
      tracking_events(:pushed).push!
    end
  end

  test "recognition of a pushable tracking event" do
    assert_predicate TrackingEvent.new(status: TrackingEvent.statuses.except(:unknown).keys.sample, pushed_at: nil), :pushable?
    assert_not_predicate TrackingEvent.new(status: "unknown", pushed_at: nil), :pushable?
    assert_not_predicate TrackingEvent.new(status: "unknown", pushed_at: Time.zone.now), :pushable?
  end

  test "recognition of a pushed tracking event" do
    assert_predicate TrackingEvent.new(pushed_at: Time.zone.now), :pushed?
    assert_not_predicate TrackingEvent.new(pushed_at: nil), :pushed?
  end
end
