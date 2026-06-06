require "rails_helper"

RSpec.describe "Admin::Recipients" do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  it "renders the index" do
    create(:recipient)
    get admin_recipients_path
    expect(response).to have_http_status(:ok)
  end

  it "creates a recipient" do
    client = create(:client)
    expect {
      post admin_recipients_path, params: {
        recipient: {
          client_id: client.id, name: "Maria", document: "1", email: "m@x.com", phone: "1",
          address_attributes: {
            street: "Rua A", number: "1", neighborhood: "Centro",
            city: "São Paulo", state: "SP", zipcode: "01001-000"
          }
        }
      }
    }.to change(Recipient, :count).by(1)
  end
end
