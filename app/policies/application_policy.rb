# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?    = staff?
  def show?     = staff?
  def create?   = staff?
  def new?      = create?
  def update?   = staff?
  def edit?     = update?
  def destroy?  = admin?

  private

  def admin?  = user&.admin?
  def staff?  = user&.admin? || user&.operator?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve = scope.all
  end
end
