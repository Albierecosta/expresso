module Auditable
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by, class_name: "User", optional: true
    belongs_to :updated_by, class_name: "User", optional: true

    before_validation :assign_audit_user
  end

  private

  def assign_audit_user
    return unless Current.user

    self.created_by ||= Current.user if new_record?
    self.updated_by   = Current.user
  end
end
