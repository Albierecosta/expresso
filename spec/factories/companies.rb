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
FactoryBot.define do
  factory :company do
    name       { "Expresso Leva e Traz" }
    legal_name { "Expresso Leva e Traz Ltda" }
    sequence(:cnpj) { |n| format("12.345.678/0001-%02d", n % 100) }
    email      { "contato@expresso.com.br" }
    phone      { "(11) 99999-9999" }
  end
end
