module Admin
  class HomeController < BaseController
    def show
      authorize :home, :show?
    end
  end
end
