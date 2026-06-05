module Public
  # Recipient-facing flow after scanning the QR code:
  #   show → photo → upload_photo → signature → sign → done
  #
  # The Delivery row is created lazily on the photo upload, then signed
  # in the final step. Re-scanning the same token after delivery shows
  # the done page; cancelled freights show a dead-end message.
  class DeliveriesController < BaseController
    before_action :find_freight
    before_action :reject_cancelled, except: :done
    before_action :redirect_if_already_delivered, only: %i[show photo upload_photo signature sign]

    def show; end

    def photo
      @delivery = @freight.delivery || @freight.build_delivery
    end

    def upload_photo
      @delivery = @freight.delivery || @freight.build_delivery

      if @delivery.update(photo_params)
        redirect_to public_delivery_signature_path(token: @freight.public_token)
      else
        render :photo, status: :unprocessable_content
      end
    end

    def signature
      @delivery = @freight.delivery
      return if @delivery&.photo&.attached?

      redirect_to public_delivery_photo_path(token: @freight.public_token)
    end

    def sign
      @delivery = @freight.delivery

      @delivery.sign(sign_params.merge(
                       ip_address: request.remote_ip,
                       user_agent: request.user_agent
                     ))

      redirect_to public_delivery_done_path(token: @freight.public_token)
    rescue ActiveRecord::RecordInvalid => e
      @delivery = e.record
      render :signature, status: :unprocessable_content
    end

    def done
      @delivery = @freight.delivery
      redirect_to public_delivery_path(token: @freight.public_token) unless @delivery&.delivered_at
    end

    private

    def find_freight
      @freight = Freight.find_by(public_token: params[:token])
      return if @freight

      render :not_found, status: :not_found, layout: "public"
    end

    def reject_cancelled
      render :cancelled, status: :gone, layout: "public" if @freight&.cancelled?
    end

    def redirect_if_already_delivered
      return unless @freight.delivered?

      redirect_to public_delivery_done_path(token: @freight.public_token)
    end

    def photo_params      = params.require(:delivery).permit(:photo)
    def sign_params       = params.require(:delivery).permit(:signature_svg, :recipient_name)
  end
end
