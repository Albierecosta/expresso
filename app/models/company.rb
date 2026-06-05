# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  cnpj       :string           not null
#  email      :string
#  legal_name :string
#  name       :string           not null
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_cnpj  (cnpj) UNIQUE
#
class Company < ApplicationRecord
  has_one_attached :logo

  validates :name, presence: true
  validates :cnpj, presence: true, uniqueness: true

  # Singleton accessor — every PDF/header pulls company data from here.
  # Returns the first persisted row, or builds one in memory so views never
  # blow up before the company is configured.
  def self.current
    first || new(name: I18n.t("app.name"))
  end
end
