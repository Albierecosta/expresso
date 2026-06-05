require "rails_helper"

RSpec.describe Statusable do
  it "wires up Enumerize predicates" do
    freight = build(:freight, :delivered)
    expect(freight).to be_delivered
    expect(freight).not_to be_pending
  end

  it "wires up Enumerize scopes" do
    create(:freight)
    delivered = create(:freight, :delivered)
    expect(Freight.with_status(:delivered)).to contain_exactly(delivered)
  end
end
