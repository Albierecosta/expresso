class RecipientPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin? || user&.operator?

      scope.none
    end
  end
end
