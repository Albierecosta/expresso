module Tokenable
  extend ActiveSupport::Concern

  TOKEN_LENGTH = 24

  included do
    before_validation :ensure_public_token, on: :create
    validates :public_token, presence: true, uniqueness: true
  end

  private

  def ensure_public_token
    return if public_token.present?

    loop do
      candidate = SecureRandom.urlsafe_base64(TOKEN_LENGTH).delete("-_").first(TOKEN_LENGTH)
      next if self.class.exists?(public_token: candidate)

      self.public_token = candidate
      break
    end
  end
end
