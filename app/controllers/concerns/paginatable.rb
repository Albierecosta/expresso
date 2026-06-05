module Paginatable
  extend ActiveSupport::Concern

  included do
    include Pagy::Backend
    helper Pagy::Frontend if respond_to?(:helper)
  end

  private

  # Usage in controllers: @pagy, @records = paginate(scope)
  def paginate(scope, **opts)
    pagy(scope, **opts)
  end
end
