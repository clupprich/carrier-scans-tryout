class TrackingEventsController < ActionController::API
  class AuthorizationError < StandardError; end

  rescue_from AuthorizationError do |error|
    Rails.logger.warn("[TrackingEvents#create] Error: #{error.message}")
    head :ok
  end

  before_action :authorize_request!

  def create
    tracking_status = TrackingEvent.normalize_value_for(:status, tracking_event_params[:status])

    TrackingEvent.create!(
      source_id: tracking_event_params[:gfsId],
      carrier: tracking_event_params[:carrierName],
      message: tracking_event_params[:text],
      tracking_number: tracking_event_params[:parcelNumber],
      status: TrackingEvent.statuses.include?(tracking_status) ? tracking_status : :unknown,
      payload: tracking_event_params.except(:tracking_events)
    )

    head :ok
  end

  private

  def authorize_request!
    request_signature = request.headers["HTTP_X_GFS_TOKEN"]
    raise AuthorizationError, "The GFS request signature is missing" if request_signature.blank?
    raise AuthorizationError, "The GFS request signature is incorrect" unless ActiveSupport::SecurityUtils.secure_compare(ENV["CARRIER_SIGNATURE"], request_signature)
  end

  def tracking_event_params
    params.permit(:gfsId, :carrierName, :consignmentNumber, :parcelNumber, :status, :text, :isDelivered)
  end
end
