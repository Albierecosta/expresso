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
class Freight < ApplicationRecord
  include Codeable
  include Tokenable
  include Statusable
  include Auditable
  include HasAddress

  code_prefix "FRETE"
  has_status %i[pending in_transit delivered cancelled], default: :pending

  belongs_to :client
  belongs_to :recipient
  belongs_to :driver, class_name: "User", optional: true

  validates :amount, presence: true, numericality: { greater_than: 0 }

  # Pre-fill the freight's own (per-delivery) address from the recipient when
  # one is associated. Lets the operator edit it without mutating the
  # recipient's default address.
  before_validation :clone_recipient_address, on: :create, if: :should_clone_address?

  scope :today, -> { where(created_at: Time.current.all_day) }
  scope :in_month, ->(date) { where(created_at: date.all_month) }
  scope :for_client, ->(client) { where(client: client) }

  ransack_alias :code_or_recipient, :code_or_recipient_name

  def self.ransackable_attributes(_auth = nil)
    %w[code status amount order_number created_at]
  end

  def self.ransackable_associations(_auth = nil)
    %w[client recipient driver]
  end

  private

  def should_clone_address?
    address.blank? && recipient&.address.present?
  end

  def clone_recipient_address
    src = recipient.address
    self.address = Address.new(src.attributes.except("id", "created_at", "updated_at",
                                                     "addressable_id", "addressable_type"))
  end
end
