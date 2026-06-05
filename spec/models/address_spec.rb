# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  addressable_type :string           not null
#  city             :string           not null
#  complement       :string
#  neighborhood     :string
#  number           :string
#  state            :string(2)        not null
#  street           :string           not null
#  zipcode          :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :bigint           not null
#
# Indexes
#
#  index_addresses_on_addressable  (addressable_type,addressable_id) UNIQUE
#
require "rails_helper"

RSpec.describe Address do
  it { is_expected.to belong_to(:addressable) }
  it { is_expected.to validate_presence_of(:street) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_length_of(:state).is_equal_to(2) }
  it { is_expected.to validate_presence_of(:zipcode) }

  describe "normalization" do
    it "upcases the state" do
      address = build(:address, state: "sp").tap(&:valid?)
      expect(address.state).to eq("SP")
    end

    it "formats CEP without dash to canonical 00000-000" do
      address = build(:address, zipcode: "01001000").tap(&:valid?)
      expect(address.zipcode).to eq("01001-000")
    end

    it "rejects malformed CEP" do
      expect(build(:address, zipcode: "abc")).not_to be_valid
    end
  end

  describe "#to_s" do
    it "joins all parts in a single human line" do
      address = build(:address,
                      street: "Rua A", number: "10",
                      neighborhood: "Centro",
                      city: "São Paulo", state: "SP",
                      zipcode: "01001-000")
      expect(address.to_s).to include("Rua A, 10", "Centro", "São Paulo - SP", "01001-000")
    end
  end
end
