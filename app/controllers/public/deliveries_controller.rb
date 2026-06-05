module Public
  # Phase 3 stub: the full flow (data → photo → signature → done) lives in
  # Phase 5. For now we just resolve the token and render a placeholder so
  # the URL helper `public_delivery_url` exists and QR codes point somewhere.
  class DeliveriesController < BaseController
    before_action :find_freight

    def show
      # Placeholder view — Phase 5 turns this into the data-confirmation step.
    end

    private

    def find_freight
      @freight = Freight.find_by!(public_token: params[:token])
    rescue ActiveRecord::RecordNotFound
      render plain: I18n.t("public.delivery.not_found", default: "Frete não encontrado."),
             status: :not_found
    end
  end
end
