# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  cnpj       :string           not null
#  email      :string
#  legal_name :string
#  name       :string           not null
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_cnpj  (cnpj) UNIQUE
#
require "rails_helper"

RSpec.describe Company do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:cnpj) }

  describe ".current" do
    it "returns the persisted company when one exists" do
      saved = create(:company)
      expect(Company.current).to eq(saved)
    end

    it "returns a new in-memory company when none exists" do
      record = Company.current
      expect(record).to be_a(Company)
      expect(record).not_to be_persisted
    end
  end
end
