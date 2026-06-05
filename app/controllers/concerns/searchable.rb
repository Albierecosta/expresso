module Searchable
  extend ActiveSupport::Concern

  private

  # Returns a Ransack search object on the given scope.
  # Defaults to ordering by created_at desc when no sort is requested.
  def search(scope, default_sort: "created_at desc")
    @q = scope.ransack(params[:q])
    @q.sorts = default_sort if @q.sorts.empty?
    @q
  end
end
