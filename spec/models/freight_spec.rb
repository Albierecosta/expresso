# == Schema Information
#
# Table name: freights
#
#  id            :bigint           not null, primary key
#  amount        :decimal(10, 2)   not null
#  code          :string           not null
#  notes         :text
#  order_number  :string
#  public_token  :string           not null
#  status        :string           default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :bigint           not null
#  created_by_id :bigint
#  driver_id     :bigint
#  recipient_id  :bigint           not null
#  updated_by_id :bigint
#
# Indexes
#
#  index_freights_on_client_id      (client_id)
#  index_freights_on_code           (code) UNIQUE
#  index_freights_on_created_by_id  (created_by_id)
#  index_freights_on_driver_id      (driver_id)
#  index_freights_on_public_token   (public_token) UNIQUE
#  index_freights_on_recipient_id   (recipient_id)
#  index_freights_on_status         (status)
#  index_freights_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (driver_id => users.id)
#  fk_rails_...  (recipient_id => recipients.id)
#  fk_rails_...  (updated_by_id => users.id)
#
require "rails_helper"

RSpec.describe Freight do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:recipient) }
  it { is_expected.to belong_to(:driver).class_name("User").optional }
  it { is_expected.to have_one(:address).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }

  describe "factory" do
    it "produces a valid record" do
      expect(build(:freight)).to be_valid
    end

    it "auto-generates code, public_token and address on create" do
      freight = create(:freight)
      expect(freight.code).to match(/\AFRETE-\d{4}-\d{2}-\d{4}\z/)
      expect(freight.public_token).to be_present
      expect(freight.address).to be_present
    end
  end

  describe "status enum" do
    let(:freight) { build(:freight) }

    it "defaults to pending" do
      expect(freight.status.value).to eq("pending")
      expect(freight).to be_pending
    end

    it "exposes scopes" do
      pending_freight  = create(:freight)
      delivered_freight = create(:freight, :delivered)

      expect(Freight.with_status(:pending)).to include(pending_freight)
      expect(Freight.with_status(:pending)).not_to include(delivered_freight)
    end
  end
end
