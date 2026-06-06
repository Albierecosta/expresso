require "rails_helper"

RSpec.describe "Admin::Drivers" do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  it "lists only drivers, not operators" do
    driver   = create(:user, :driver)
    create(:user) # operator — should be filtered out by DriverPolicy::Scope

    get admin_drivers_path
    expect(response.body).to include(driver.name)
  end

  it "creates a driver" do
    expect {
      post admin_drivers_path, params: {
        user: { name: "José Motorista", email: "j@x.com",
                password: "password123", password_confirmation: "password123" }
      }
    }.to change { User.with_role(:driver).count }.by(1)
  end

  it "blocks operators from creating" do
    sign_in create(:user) # operator
    post admin_drivers_path, params: { user: { name: "x", email: "x@x.com" } }
    expect(response).to redirect_to(root_path)
  end
end
