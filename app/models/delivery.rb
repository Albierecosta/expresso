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
class Delivery < ApplicationRecord
  has_one_attached :photo

  belongs_to :freight

  # We mark the freight as delivered exactly when the signature lands —
  # that's the "completed" moment from the recipient's perspective.
  validates :signature_svg, :recipient_name, :delivered_at, presence: true, on: :sign

  def sign(attrs)
    assign_attributes(attrs.merge(delivered_at: Time.current))

    transaction do
      save!(context: :sign)
      freight.update!(status: :delivered)
    end
  end
end
