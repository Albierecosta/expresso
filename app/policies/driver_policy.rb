class DriverPolicy < ApplicationPolicy
  # Drivers are User records with role :driver. Only admins manage them
  # — operators can read but not write, drivers can't touch the list.
  def index?   = user&.admin? || user&.operator?
  def show?    = index?
  def create?  = user&.admin?
  def new?     = create?
  def update?  = user&.admin?
  def edit?    = update?
  def destroy? = user&.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.with_role(:driver) if user&.admin? || user&.operator?

      scope.none
    end
  end
end
