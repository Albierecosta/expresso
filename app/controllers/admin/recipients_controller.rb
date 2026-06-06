module Admin
  class RecipientsController < BaseController
    before_action :set_recipient, only: %i[show edit update destroy]

    def index
      scope    = policy_scope(Recipient).includes(:client, :address)
      @pagy, @recipients = paginate(search(scope).result)
    end

    def show
      authorize @recipient
    end

    def new
      @recipient = Recipient.new(client_id: params[:client_id])
      @recipient.build_address
      authorize @recipient
    end

    def create
      @recipient = Recipient.new(recipient_params)
      authorize @recipient

      if @recipient.save
        redirect_to admin_recipient_path(@recipient),
                    notice: t("flash.created", resource: Recipient.model_name.human)
      else
        @recipient.build_address if @recipient.address.blank?
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @recipient
      @recipient.build_address if @recipient.address.blank?
    end

    def update
      authorize @recipient

      if @recipient.update(recipient_params)
        redirect_to admin_recipient_path(@recipient),
                    notice: t("flash.updated", resource: Recipient.model_name.human)
      else
        @recipient.build_address if @recipient.address.blank?
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @recipient
      @recipient.destroy
      redirect_to admin_recipients_path,
                  notice: t("flash.destroyed", resource: Recipient.model_name.human)
    end

    private

    def set_recipient
      @recipient = Recipient.find(params[:id])
    end

    def recipient_params
      params.require(:recipient).permit(
        :client_id, :name, :document, :email, :phone,
        address_attributes: %i[id street number complement neighborhood city state zipcode]
      )
    end
  end
end
