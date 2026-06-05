# == Schema Information
#
# Table name: recipients
#
#  id            :bigint           not null, primary key
#  document      :string
#  email         :string
#  name          :string           not null
#  phone         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :bigint           not null
#  created_by_id :bigint
#  updated_by_id :bigint
#
# Indexes
#
#  index_recipients_on_client_id      (client_id)
#  index_recipients_on_created_by_id  (created_by_id)
#  index_recipients_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
FactoryBot.define do
  factory :recipient do
    client          { association(:client) }
    sequence(:name)  { |n| "Maria Souza ##{n}" }
    document         { "123.456.789-00" }
    sequence(:email) { |n| "destinatario#{n}@exemplo.com" }
    phone            { "(11) 99999-9999" }

    after(:build) do |recipient|
      recipient.address ||= build(:address, addressable: recipient)
    end

    trait(:without_address) do
      after(:build) { |r| r.address = nil }
    end
  end
end
