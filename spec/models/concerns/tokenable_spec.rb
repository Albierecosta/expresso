require "rails_helper"

RSpec.describe Tokenable do
  describe "auto-generated public_token on Freight" do
    it "is a URL-safe string of the configured length" do
      freight = create(:freight)
      expect(freight.public_token.length).to eq(Tokenable::TOKEN_LENGTH)
      expect(freight.public_token).to match(/\A[A-Za-z0-9]+\z/)
    end

    it "is unique across records" do
      tokens = Array.new(3) { create(:freight).public_token }
      expect(tokens.uniq.length).to eq(3)
    end
  end
end
