require "rails_helper"

RSpec.describe Auditable do
  let(:user) { create(:user) }

  before { Current.user = user }
  after  { Current.user = nil }

  it "sets created_by and updated_by from Current.user on create" do
    client = create(:client)
    expect(client.created_by).to eq(user)
    expect(client.updated_by).to eq(user)
  end

  it "updates only updated_by on subsequent updates" do
    client = create(:client)
    other  = create(:user)
    Current.user = other

    client.update!(name: "Renamed Ltda")

    expect(client.created_by).to eq(user)
    expect(client.updated_by).to eq(other)
  end

  it "does not error when Current.user is nil" do
    Current.user = nil
    expect { create(:client) }.not_to raise_error
  end
end
