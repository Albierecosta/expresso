module Admin
  # The singleton Company config — there's at most one row in the DB.
  # We expose only show/edit/update via a Rails singleton resource.
  class CompaniesController < BaseController
    before_action :set_company

    def show
      authorize @company
    end

    def edit
      authorize @company
    end

    def update
      authorize @company

      if @company.update(company_params)
        redirect_to admin_company_path,
                    notice: t("flash.updated", resource: Company.model_name.human)
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_company
      @company = Company.first_or_initialize(name: I18n.t("app.name"))
    end

    def company_params
      params.require(:company).permit(:name, :legal_name, :cnpj, :email, :phone, :logo)
    end
  end
end
