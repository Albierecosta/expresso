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
require "rails_helper"

RSpec.describe Client do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:recipients).dependent(:destroy) }
  it { is_expected.to have_one(:address).dependent(:destroy) }

  it "has a valid factory" do
    expect(build(:client)).to be_valid
  end

  it "is invalid without an address (Addressable concern)" do
    expect(build(:client, :without_address)).not_to be_valid
  end

  it "destroys its address on destroy" do
    client = create(:client)
    address_id = client.address.id
    expect { client.destroy }.to change { Address.exists?(address_id) }.from(true).to(false)
  end
end
