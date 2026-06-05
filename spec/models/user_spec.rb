# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("operator"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "rails_helper"

RSpec.describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }

  describe "role" do
    it "defaults to operator" do
      expect(build(:user).role).to eq("operator")
    end

    it "exposes predicates" do
      expect(build(:user, :admin).admin?).to be(true)
      expect(build(:user, :driver).driver?).to be(true)
    end

    it "rejects unknown roles" do
      expect(build(:user, role: :hacker)).not_to be_valid
    end
  end
end
