# Demo data for kicking the tires on a fresh DB.
# Run: bin/rails db:seed
#
# Idempotent — re-running won't create duplicates.

Company.first_or_create!(
  name: "Expresso Leva e Traz",
  legal_name: "Expresso Leva e Traz Ltda",
  cnpj: "12.345.678/0001-90",
  email: "contato@expresso.com.br",
  phone: "(11) 99999-9999"
)

admin = User.find_or_initialize_by(email: "admin@expresso.test")
admin.update!(
  name: "João Admin",
  role: :admin,
  password: "password123",
  password_confirmation: "password123"
)
puts "✓ admin: #{admin.email} / password123"

driver = User.find_or_initialize_by(email: "motorista@expresso.test")
driver.update!(
  name: "Carlos Motorista",
  role: :driver,
  password: "password123",
  password_confirmation: "password123"
)
puts "✓ motorista: #{driver.email} / password123"

[
  { name: "Comércio São João Ltda", document: "12.345.678/0001-90",
    email: "sj@x.com", phone: "(11) 3333-1111" },
  { name: "Mercado Bom Preço",     document: "11.222.333/0001-44",
    email: "bp@x.com", phone: "(11) 3333-2222" },
  { name: "Padaria Pão Quente",    document: "55.666.777/0001-88",
    email: "pq@x.com", phone: "(11) 3333-3333" }
].each do |attrs|
  client = Client.find_or_initialize_by(name: attrs[:name])
  next if client.persisted?

  client.assign_attributes(attrs)
  client.address = Address.new(
    street: "Av. Paulista", number: "1000", neighborhood: "Bela Vista",
    city: "São Paulo", state: "SP", zipcode: "01310-100"
  )
  client.save!
  puts "✓ cliente: #{client.name}"
end

sao_joao = Client.find_by(name: "Comércio São João Ltda")

[
  { name: "Maria Souza",   document: "111.222.333-44", phone: "(11) 98888-1111" },
  { name: "José da Silva", document: "222.333.444-55", phone: "(11) 98888-2222" }
].each do |attrs|
  recipient = Recipient.find_or_initialize_by(name: attrs[:name], client: sao_joao)
  next if recipient.persisted?

  recipient.assign_attributes(attrs)
  recipient.address = Address.new(
    street: "Rua das Flores", number: "123", neighborhood: "Centro",
    city: "São Paulo", state: "SP", zipcode: "01001-000"
  )
  recipient.save!
  puts "✓ destinatário: #{recipient.name}"
end

if Freight.none?
  Recipient.find_each.with_index do |recipient, i|
    Freight.create!(
      client: recipient.client,
      recipient: recipient,
      amount: 35 + (i * 10),
      order_number: "PED#{1000 + i}",
      notes: ([ "Entrega no balcão", "Deixar com o porteiro", nil ][i % 3])
    )
  end
  puts "✓ fretes: #{Freight.count} criados"
end
