module Admin
  class FreightsController < BaseController
    before_action :set_freight, only: %i[show edit update destroy print]

    def index
      scope    = policy_scope(Freight).includes(:client, :recipient, :driver, :address)
      relation = search(scope).result
      @pagy, @freights = paginate(relation)
    end

    def show
      authorize @freight
    end

    def new
      @freight = Freight.new
      @freight.build_address
      authorize @freight
    end

    def create
      @freight = Freight.new(freight_params)
      authorize @freight

      if @freight.save
        redirect_to admin_freight_path(@freight),
                    notice: t("flash.created", resource: Freight.model_name.human)
      else
        @freight.build_address if @freight.address.blank?
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @freight
      @freight.build_address if @freight.address.blank?
    end

    def update
      authorize @freight

      if @freight.update(freight_params)
        redirect_to admin_freight_path(@freight),
                    notice: t("flash.updated", resource: Freight.model_name.human)
      else
        @freight.build_address if @freight.address.blank?
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @freight
      @freight.destroy
      redirect_to admin_freights_path,
                  notice: t("flash.destroyed", resource: Freight.model_name.human)
    end

    def print
      authorize @freight, :show?
      render layout: "print"
    end

    private

    def set_freight
      @freight = Freight.find(params[:id])
    end

    def freight_params
      params.require(:freight).permit(
        :client_id, :recipient_id, :driver_id,
        :amount, :order_number, :notes, :status,
        address_attributes: %i[id street number complement neighborhood city state zipcode]
      )
    end
  end
end
