class ReportPolicy < Struct.new(:user, :report)
  def show?    = user&.admin? || user&.operator?
  def monthly? = show?
  alias_method :monthly_pdf?, :show?
end
