require "rails_helper"

RSpec.describe FreightPolicy do
  subject(:policy) { described_class.new(user, freight) }

  let(:freight) { create(:freight) }

  context "as admin" do
    let(:user) { create(:user, :admin) }

    it("allows show")    { expect(policy.show?).to be true }
    it("allows create")  { expect(policy.create?).to be true }
    it("allows update")  { expect(policy.update?).to be true }
    it("allows destroy") { expect(policy.destroy?).to be true }
  end

  context "as operator" do
    let(:user) { create(:user) } # default role

    it("allows show")    { expect(policy.show?).to be true }
    it("allows create")  { expect(policy.create?).to be true }
    it("blocks destroy") { expect(policy.destroy?).to be false }
  end

  context "as driver assigned to the freight" do
    let(:user) { create(:user, :driver) }
    let(:freight) { create(:freight, driver: user) }

    it("allows show")    { expect(policy.show?).to be true }
    it("blocks update")  { expect(policy.update?).to be false }
  end

  context "as driver not assigned to the freight" do
    let(:user) { create(:user, :driver) }

    it("blocks show") { expect(policy.show?).to be false }
  end

  describe "Scope" do
    let!(:f1) { create(:freight) }
    let!(:f2) { create(:freight, :with_driver) }

    it "returns all for staff" do
      admin = create(:user, :admin)
      expect(described_class::Scope.new(admin, Freight).resolve).to match_array([ f1, f2 ])
    end

    it "returns only own freights for drivers" do
      driver = f2.driver
      expect(described_class::Scope.new(driver, Freight).resolve).to contain_exactly(f2)
    end
  end
end
