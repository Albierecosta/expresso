class CompanyPolicy < ApplicationPolicy
  def show?   = user&.admin? || user&.operator?
  def edit?   = user&.admin?
  def update? = user&.admin?
end
