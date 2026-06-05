module Codeable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_code, on: :create
    validates :code, presence: true, uniqueness: true
  end

  class_methods do
    # Set the prefix shown in the code (e.g. "FRETE" → FRETE-2026-06-0001).
    def code_prefix(prefix)
      @code_prefix = prefix.to_s.upcase
    end

    def configured_code_prefix
      @code_prefix or raise NotImplementedError,
        "#{name} includes Codeable but did not call `code_prefix \"...\"`"
    end
  end

  private

  def ensure_code
    return if code.present?

    self.code = next_code
  end

  # Sequence scoped by year+month, e.g. FRETE-2026-06-0001
  def next_code
    today  = Date.current
    prefix = "#{self.class.configured_code_prefix}-#{today.strftime("%Y-%m")}"
    last   = self.class.where("code LIKE ?", "#{prefix}-%").order(:code).last
    seq    = last ? last.code.split("-").last.to_i + 1 : 1
    format("%s-%04d", prefix, seq)
  end
end
