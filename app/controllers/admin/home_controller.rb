module Admin
  class HomeController < BaseController
    def show
      authorize :home, :show?

      scope = policy_scope(Freight)
      @counts = scope.group(:status).count
      @today_freights = scope.today.recent.includes(:client, :recipient).limit(5)
    end
  end
end
