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
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, inverse_of: :address

  validates :street,  presence: true
  validates :city,    presence: true
  validates :state,   presence: true, length: { is: 2 }
  validates :zipcode, presence: true, format: { with: /\A\d{5}-?\d{3}\z/, message: :invalid }

  before_validation :normalize_state
  before_validation :normalize_zipcode

  def to_s
    parts = [
      [ street, number ].compact_blank.join(", "),
      complement.presence,
      neighborhood.presence,
      "#{city} - #{state}",
      zipcode.presence
    ].compact_blank
    parts.join(" · ")
  end

  private

  def normalize_state
    self.state = state.to_s.upcase.strip if state.present?
  end

  def normalize_zipcode
    return if zipcode.blank?

    digits = zipcode.gsub(/\D/, "")
    self.zipcode = digits.length == 8 ? "#{digits[0, 5]}-#{digits[5, 3]}" : zipcode
  end
end
