require "rails_helper"

RSpec.describe "Admin::Freights" do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe "GET /admin/freights" do
    it "renders the index" do
      create(:freight)
      get admin_freights_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/freights/new" do
    it "renders the form" do
      get new_admin_freight_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/freights" do
    let(:client) { create(:client) }
    let(:recipient) { create(:recipient, client: client) }
    let(:valid_params) do
      {
        freight: {
          client_id: client.id,
          recipient_id: recipient.id,
          amount: "57.50",
          order_number: "PED-1",
          notes: "deixa na portaria",
          address_attributes: {
            street: "Rua A", number: "10", neighborhood: "Centro",
            city: "São Paulo", state: "SP", zipcode: "01001-000"
          }
        }
      }
    end

    it "creates a freight and redirects to its show page" do
      expect { post admin_freights_path, params: valid_params }
        .to change(Freight, :count).by(1)

      expect(response).to redirect_to(admin_freight_path(Freight.last))
    end

    it "re-renders the form on validation error" do
      post admin_freights_path, params: valid_params.deep_merge(freight: { amount: "0" })
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /admin/freights/:id" do
    it "renders the show page with QR panel" do
      freight = create(:freight)
      get admin_freight_path(freight)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(freight.code)
      expect(response.body).to include("<svg") # QR code SVG inline
    end
  end

  describe "GET /admin/freights/:id/print" do
    it "renders using the print layout" do
      freight = create(:freight)
      get print_admin_freight_path(freight)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Etiqueta de Frete")
    end
  end

  describe "DELETE /admin/freights/:id" do
    it "removes the freight" do
      freight = create(:freight)
      expect { delete admin_freight_path(freight) }
        .to change(Freight, :count).by(-1)
    end
  end
end
