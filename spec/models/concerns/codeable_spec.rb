require "rails_helper"

RSpec.describe Codeable do
  describe "auto-generated code on Freight (which uses Codeable)" do
    it "is FRETE-YYYY-MM-NNNN format" do
      freight = create(:freight)
      expect(freight.code).to match(/\AFRETE-\d{4}-\d{2}-\d{4}\z/)
    end

    it "increments the sequence per month" do
      first  = create(:freight)
      second = create(:freight)

      expect(first.code.split("-").last.to_i).to eq(1)
      expect(second.code.split("-").last.to_i).to eq(2)
    end

    it "is unique" do
      freight = create(:freight)
      duplicate = build(:freight, code: freight.code)
      expect(duplicate).not_to be_valid
    end
  end
end
