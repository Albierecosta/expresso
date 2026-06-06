module Admin
  # Drivers are just Users scoped to `role: :driver`. We give them their
  # own admin namespace so the sidebar link, breadcrumbs and form labels
  # match the user's mental model ("motorista") rather than "user".
  class DriversController < BaseController
    before_action :set_driver, only: %i[show edit update destroy]

    def index
      scope = policy_scope(User, policy_scope_class: DriverPolicy::Scope)
      @pagy, @drivers = paginate(search(scope).result)
    end

    def show
      authorize @driver, policy_class: DriverPolicy
    end

    def new
      @driver = User.new(role: :driver)
      authorize @driver, policy_class: DriverPolicy
    end

    def create
      @driver = User.new(driver_params.merge(role: :driver))
      authorize @driver, policy_class: DriverPolicy

      if @driver.save
        redirect_to admin_driver_path(@driver),
                    notice: t("flash.created", resource: "Motorista")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @driver, policy_class: DriverPolicy
    end

    def update
      authorize @driver, policy_class: DriverPolicy

      attrs = driver_params
      attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?

      if @driver.update(attrs)
        redirect_to admin_driver_path(@driver),
                    notice: t("flash.updated", resource: "Motorista")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @driver, policy_class: DriverPolicy
      @driver.destroy
      redirect_to admin_drivers_path,
                  notice: t("flash.destroyed", resource: "Motorista")
    end

    private

    def set_driver
      @driver = User.with_role(:driver).find(params[:id])
    end

    def driver_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
end
