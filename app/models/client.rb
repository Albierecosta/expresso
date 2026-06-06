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
class Client < ApplicationRecord
  include HasAddress
  include Auditable

  has_many :recipients, dependent: :destroy
  has_many :freights, dependent: :restrict_with_error

  validates :name, presence: true

  def self.ransackable_attributes(_auth = nil)
    %w[name document email phone created_at]
  end
end
