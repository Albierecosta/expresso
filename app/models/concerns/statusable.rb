module Statusable
  extend ActiveSupport::Concern

  included do
    extend Enumerize
  end

  class_methods do
    # Declares a :status enumerize attribute with predicates and scopes.
    # Usage: has_status %i[pending in_transit delivered cancelled], default: :pending
    def has_status(values, default: values.first)
      enumerize :status,
                in: values,
                default: default,
                predicates: true,
                scope: true
    end
  end
end
