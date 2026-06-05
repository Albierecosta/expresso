# Renamed from `Addressable` because the `addressable` gem (transitive dep)
# defines a top-level `Addressable` module that shadows ours via Zeitwerk.
module HasAddress
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable

    accepts_nested_attributes_for :address, update_only: true

    validates :address, presence: true
  end
end
