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
FactoryBot.define do
  factory :freight do
    client    { association(:client) }
    recipient { association(:recipient, client: client) }
    amount    { 45.0 }
    status    { :pending }
    # code + public_token + address are filled by Codeable/Tokenable callbacks
    # and the clone_recipient_address before_validation.

    trait(:in_transit) { status { :in_transit } }
    trait(:delivered)  { status { :delivered } }
    trait(:cancelled)  { status { :cancelled } }

    trait(:with_driver) { driver { association(:user, :driver) } }
  end
end
