class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Newest first by default — every index defaults to this unless overridden.
  scope :recent, -> { order(created_at: :desc) }
end
