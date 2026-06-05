# == Schema Information
#
# Table name: deliveries
#
#  id             :bigint           not null, primary key
#  delivered_at   :datetime
#  ip_address     :string
#  recipient_name :string
#  signature_svg  :text
#  user_agent     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  freight_id     :bigint           not null
#
# Indexes
#
#  index_deliveries_on_freight_id  (freight_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (freight_id => freights.id)
#
require "rails_helper"

RSpec.describe Delivery do
  it { is_expected.to belong_to(:freight) }

  describe "#sign" do
    let(:freight)  { create(:freight) }
    let(:delivery) { freight.create_delivery! }

    it "stores signature + recipient + audit info and stamps delivered_at" do
      delivery.sign(
        signature_svg: "<svg>...</svg>",
        recipient_name: "Maria Souza",
        ip_address: "10.0.0.1",
        user_agent: "Chrome"
      )

      expect(delivery.reload).to have_attributes(
        signature_svg: "<svg>...</svg>",
        recipient_name: "Maria Souza",
        ip_address: "10.0.0.1",
        user_agent: "Chrome"
      )
      expect(delivery.delivered_at).to be_within(2.seconds).of(Time.current)
    end

    it "transitions the parent freight to :delivered" do
      expect {
        delivery.sign(signature_svg: "<svg>", recipient_name: "M", ip_address: "1.1.1.1", user_agent: "X")
      }.to change { freight.reload.status.value }.from("pending").to("delivered")
    end

    it "rolls back the freight when the signature payload is missing" do
      expect {
        delivery.sign(signature_svg: nil, recipient_name: "Maria", ip_address: "x", user_agent: "y")
      }.to raise_error(ActiveRecord::RecordInvalid)
      expect(freight.reload).to be_pending
    end
  end
end
