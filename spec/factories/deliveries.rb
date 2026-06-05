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
FactoryBot.define do
  factory :delivery do
    freight        { association(:freight) }
    signature_svg  { "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciLz4=" }
    recipient_name { "Maria Souza" }
    delivered_at   { Time.current }
    ip_address     { "127.0.0.1" }
    user_agent     { "RSpec" }
  end
end
