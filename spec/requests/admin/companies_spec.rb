require "rails_helper"

RSpec.describe "Admin::Companies" do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  it "renders show even when no company exists yet" do
    get admin_company_path
    expect(response).to have_http_status(:ok)
  end

  it "creates the company on first update" do
    expect {
      patch admin_company_path, params: {
        company: {
          name: "Expresso Leva e Traz",
          legal_name: "Expresso Ltda",
          cnpj: "12.345.678/0001-90",
          email: "contato@expresso.com.br",
          phone: "(11) 99999-9999"
        }
      }
    }.to change(Company, :count).by(1)
  end
end
