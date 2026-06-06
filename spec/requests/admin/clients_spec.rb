require "rails_helper"

RSpec.describe "Admin::Clients" do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  it "renders the index" do
    create(:client)
    get admin_clients_path
    expect(response).to have_http_status(:ok)
  end

  it "renders new form" do
    get new_admin_client_path
    expect(response).to have_http_status(:ok)
  end

  it "creates a client with nested address" do
    expect {
      post admin_clients_path, params: {
        client: {
          name: "Novo Comércio", document: "12.345.678/0001-90",
          email: "c@x.com", phone: "(11) 99999-9999",
          address_attributes: {
            street: "Rua A", number: "1", neighborhood: "Centro",
            city: "São Paulo", state: "SP", zipcode: "01001-000"
          }
        }
      }
    }.to change(Client, :count).by(1)

    expect(response).to redirect_to(admin_client_path(Client.last))
  end

  it "shows a client" do
    client = create(:client)
    get admin_client_path(client)
    expect(response).to have_http_status(:ok)
  end

  it "destroys a client without freights" do
    client = create(:client)
    expect { delete admin_client_path(client) }.to change(Client, :count).by(-1)
  end
end
