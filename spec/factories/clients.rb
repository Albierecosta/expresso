# == Schema Information
#
# Table name: clients
#
#  id            :bigint           not null, primary key
#  document      :string
#  email         :string
#  name          :string           not null
#  phone         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint
#  updated_by_id :bigint
#
# Indexes
#
#  index_clients_on_created_by_id  (created_by_id)
#  index_clients_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
FactoryBot.define do
  factory :client do
    sequence(:name)  { |n| "Comércio #{n} Ltda" }
    document         { "12.345.678/0001-90" }
    sequence(:email) { |n| "cliente#{n}@exemplo.com" }
    phone            { "(11) 99999-9999" }

    after(:build) do |client|
      client.address ||= build(:address, addressable: client)
    end

    trait(:without_address) do
      after(:build) { |c| c.address = nil }
    end
  end
end
