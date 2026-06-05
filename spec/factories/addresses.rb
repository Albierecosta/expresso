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
FactoryBot.define do
  factory :address do
    street       { "Rua das Flores" }
    number       { "123" }
    neighborhood { "Centro" }
    city         { "São Paulo" }
    state        { "SP" }
    zipcode      { "01001-000" }
    addressable  { association(:client, :without_address) }
  end
end
