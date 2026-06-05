class FreightPolicy < ApplicationPolicy
  # All defaults inherited: staff (admin|operator) reads/writes, admin destroys.
  # Drivers can only see their own freights.
  def show?
    staff? || own_freight?
  end

  private

  def own_freight?
    user&.driver? && record.driver_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all                    if user&.admin? || user&.operator?
      return scope.where(driver_id: user.id) if user&.driver?

      scope.none
    end
  end
end
