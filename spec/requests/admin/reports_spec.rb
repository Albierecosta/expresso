require "rails_helper"

RSpec.describe "Admin::Reports" do
  let(:user)   { create(:user, :admin) }
  let(:client) { create(:client) }

  before do
    sign_in user

    # Two delivered freights in the current month + one pending (should be excluded)
    @f1 = create(:freight, client: client, amount: 100)
    @f2 = create(:freight, client: client, amount: 50)
    [ @f1, @f2 ].each do |f|
      f.create_delivery!.sign(signature_svg: "<svg>", recipient_name: "M",
                              ip_address: "1.1.1.1", user_agent: "x")
    end

    create(:freight, client: client, amount: 999) # still pending
  end

  describe "GET /admin/reports/monthly" do
    it "lists delivered freights for the current month and sums the total" do
      get monthly_admin_reports_path(client_id: client.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(@f1.code, @f2.code)
      expect(response.body).not_to include("999")
      expect(response.body).to include("R$&nbsp;150,00").or include("R$ 150,00")
    end
  end

  describe "GET /admin/reports/monthly_pdf" do
    it "returns a PDF" do
      get monthly_pdf_admin_reports_path(client_id: client.id)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with("application/pdf")
      expect(response.body).to start_with("%PDF")
    end
  end
end
