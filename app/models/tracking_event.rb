class TrackingEvent < ApplicationRecord
  DEFAULT_STATUS = "unknown"

  class UnpushableError < StandardError; end

  enum :status, { waiting: "waiting", in_transit: "in_transit", out_for_delivery: "out_for_delivery", delivered: "delivered", exception: "exception", returned: "returned", failure: "failure", other: "other", unknown: "unknown" }, default: "unknown", validate: true

  normalizes :status, with: ->(status) { status.to_s.gsub(/[-\s]+/, "_").parameterize(separator: "_") }

  validates :source_id, :carrier, :message, :tracking_number, presence: true

  serialize :payload, coder: JSON
  encrypts :payload

  after_create_commit :detect_status_later, if: :unknown?
  after_commit :push_later, if: :pushable?

  # Finds the associated customer shipment in Fulfil.
  #
  # @return [FulfilApi::Resource, nil]
  def customer_shipment
    @customer_shipment ||=
      FulfilApi::Resource
        .set(model_name: "stock.shipment.out")
        .select("id", "number", "tracking_number.tracking_number")
        .find_by([ "tracking_number.tracking_number", "=", tracking_number ])
  end

  # Uses the `TrackingEvent#details` to normalize the `TrackingEvent#status` when possible.
  #
  # @return [TrackingEvent]
  def detect_status
    status_detection = StatusDetection.new(self)
    update(status: status_detection.outcome)
  end

  def detect_status_later
    TrackingEvents::StatusDetectionJob.perform_later(self)
  end

  # Pushes the `TrackingEvent` to Fulfil.
  #
  # @param include_on_timeline [true, false]
  # @return [TrackingEvent]
  def push!(include_on_timeline: true)
    raise(UnpushableError, "can't push to Fulfil because the status is not normalized yet") if unknown?
    raise(UnpushableError, "can't push to Fulfil because it is already pushed") if pushed?

    leave_note_on_customer_shipment if include_on_timeline
    update!(pushed_at: Time.zone.now)
  end

  def push_later
    TrackingEvents::PushJob.perform_later(self)
  end

  # @return [true, false]
  def pushable?
    !pushed? && !unknown?
  end

  # @return [true, false]
  def pushed?
    pushed_at.present?
  end

  private

  def leave_note_on_customer_shipment
    FulfilApi.client.post(
      "/model/ir.note",
      body: [ { resource: "stock.shipment.out,#{customer_shipment["id"]}", message: } ]
    )
  end
end
