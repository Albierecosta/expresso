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
require "rails_helper"

RSpec.describe Recipient do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_one(:address).dependent(:destroy) }

  it "has a valid factory" do
    expect(build(:recipient)).to be_valid
  end

  it "is invalid without an address" do
    expect(build(:recipient, :without_address)).not_to be_valid
  end
end
