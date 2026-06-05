class HomePolicy < Struct.new(:user, :home)
  def show?
    user.present?
  end
end
