module Admin
  class ReportsController < BaseController
    before_action :build_filter

    def index
      redirect_to action: :monthly
    end

    def monthly
      authorize :report, :show?
      @freights = filtered_freights.includes(:recipient).recent
      @total    = @freights.sum(:amount)
    end

    def monthly_pdf
      authorize :report, :show?
      pdf = RelatorioMensalPdf.new(client: @client, date: @date, freights: filtered_freights).render
      send_data pdf,
                filename: "relatorio-#{@client&.id || 'todos'}-#{@date.strftime("%Y-%m")}.pdf",
                type: "application/pdf",
                disposition: "inline"
    end

    private

    def build_filter
      @date   = parse_date(params[:date])
      @client = Client.find_by(id: params[:client_id])
      @clients = Client.order(:name)
    end

    def parse_date(value)
      Date.parse(value)
    rescue ArgumentError, TypeError
      Date.current
    end

    def filtered_freights
      scope = policy_scope(Freight).with_status(:delivered).in_month(@date)
      scope = scope.for_client(@client) if @client
      scope
    end
  end
end
