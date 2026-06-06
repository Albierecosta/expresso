module Admin
  class ClientsController < BaseController
    before_action :set_client, only: %i[show edit update destroy]

    def index
      scope    = policy_scope(Client).includes(:address)
      @pagy, @clients = paginate(search(scope).result)
    end

    def show
      authorize @client
      @freights = @client.freights.recent.includes(:recipient).limit(10) if @client.respond_to?(:freights)
    end

    def new
      @client = Client.new
      @client.build_address
      authorize @client
    end

    def create
      @client = Client.new(client_params)
      authorize @client

      if @client.save
        redirect_to admin_client_path(@client),
                    notice: t("flash.created", resource: Client.model_name.human)
      else
        @client.build_address if @client.address.blank?
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @client
      @client.build_address if @client.address.blank?
    end

    def update
      authorize @client

      if @client.update(client_params)
        redirect_to admin_client_path(@client),
                    notice: t("flash.updated", resource: Client.model_name.human)
      else
        @client.build_address if @client.address.blank?
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @client
      @client.destroy
      redirect_to admin_clients_path,
                  notice: t("flash.destroyed", resource: Client.model_name.human)
    end

    private

    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(
        :name, :document, :email, :phone,
        address_attributes: %i[id street number complement neighborhood city state zipcode]
      )
    end
  end
end
