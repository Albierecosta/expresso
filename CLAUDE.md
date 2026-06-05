# Expresso Leva e Traz — Guia de Desenvolvimento

Sistema web de gestão de fretes com comprovação digital (QR Code + foto + assinatura).

## Stack

- **Ruby** 3.3.0
- **Rails** 8.0.5 (modo full-stack, sem API mode)
- **PostgreSQL** 17
- **Hotwire** (Turbo + Stimulus) — SPA feel sem JS framework
- **TailwindCSS** v4 — UI responsiva (admin web + telas mobile do destinatário)
- **importmap-rails** — sem Node/Webpack
- **Solid Queue / Cache / Cable** — backends padrão do Rails 8, sem Redis

### Gems principais

| Gem | Função |
|---|---|
| `devise` | Autenticação |
| `pundit` | Autorização (policies por recurso) |
| `enumerize` | **Gem de enum escolhida** — suporta I18n, validações, scopes, predicados |
| `rqrcode` | Geração de QR Code (SVG/PNG) |
| `prawn` + `prawn-table` | PDF de comprovante e relatório mensal |
| `image_processing` | Variants do Active Storage (thumb da foto de entrega) |
| `pagy` | Paginação leve |
| `ransack` | Filtros nos índices (Fretes, Clientes, etc.) |
| `simple_form` | Formulários DRY |
| `annotaterb` | Anota schema nos models |
| `rubocop-rails-omakase` | Lint padrão Rails |
| `brakeman` | Análise de segurança |
| `factory_bot_rails`, `rspec-rails`, `faker`, `capybara`, `selenium-webdriver` | Testes |

---

## Princípios de código

1. **DRY radical** — qualquer lógica repetida vira concern, partial, helper ou service.
2. **Fat models, skinny controllers** — controllers só orquestram; regra de negócio em models/concerns/services.
3. **Concerns** em `app/models/concerns/` e `app/controllers/concerns/` para tudo que aparece em 2+ lugares.
4. **Partials** em `app/views/shared/` para qualquer bloco de UI usado mais de uma vez (form, card, badge, table_row).
5. **Enums sempre via `enumerize`** — nunca enum nativo do Rails. Garante I18n e DRY entre views.
6. **I18n 100% pt-BR** — nenhuma string hardcoded em view ou flash.
7. **Hotwire-first** — Turbo Frames/Streams antes de pensar em JS custom.
8. **Policies sempre** — controller herda de `ApplicationController` que faz `verify_authorized` após cada action.

---

## Modelagem de dados

### Entidades

```
User (admin | motorista | operador)
 └─ has_many :freights (as creator)

Company (dados da transportadora — CNPJ, contato, logo)
 └─ singleton: Company.current

Client (empresa contratante do frete — ex: Comércio São João Ltda)
 ├─ has_many :recipients
 ├─ has_many :freights
 └─ has_one :address (polymorphic)

Recipient (destinatário final — ex: Maria Souza)
 ├─ belongs_to :client
 ├─ has_one :address (polymorphic)
 └─ has_many :freights

Driver (motorista — opcional, pode ser User com role)
 └─ has_many :freights

Address (polymorphic: addressable_type/_id)

Freight (frete — entidade central)
 ├─ belongs_to :client
 ├─ belongs_to :recipient
 ├─ belongs_to :driver, optional: true
 ├─ belongs_to :created_by, class_name: 'User'
 ├─ has_one :delivery
 ├─ has_one_attached :qr_code_image
 ├─ enumerize :status, in: %i[pending in_transit delivered cancelled]
 └─ code (FRETE-YYYY-MM-NNNN, gerado por concern)

Delivery (comprovação de entrega)
 ├─ belongs_to :freight
 ├─ has_one_attached :photo
 ├─ signature_svg :text (SVG da assinatura capturada)
 ├─ recipient_name :string (quem assinou, pode diferir do destinatário cadastrado)
 ├─ delivered_at :datetime
 └─ ip_address, user_agent (auditoria)
```

### Concerns de model (planejados)

- `HasAddress` — adiciona `has_one :address, as: :addressable, dependent: :destroy` + `accepts_nested_attributes_for`. (Renomeado de `Addressable` para evitar shadowing pela gem homônima.)
- `Codeable` — gera código único sequencial com prefixo (`FRETE-YYYY-MM-NNNN`). Usado em `Freight`.
- `Tokenable` — gera token público URL-safe para links de QR Code (`freight.public_token`).
- `Auditable` — adiciona `created_by`/`updated_by` automaticamente via `Current.user`.
- `Searchable` — wrapper sobre Ransack com defaults consistentes (sort por `created_at desc`).
- `Statusable` — helpers genéricos para badges de status (cor por valor de enumerize).

### Concerns de controller

- `Authenticatable` — `before_action :authenticate_user!` + carrega `Current.user`.
- `Authorizable` — `after_action :verify_authorized` + tratamento de `Pundit::NotAuthorizedError`.
- `Paginatable` — método `paginate(scope)` usando Pagy.
- `Searchable` — método `search(scope)` usando Ransack a partir de `params[:q]`.

---

## Estrutura de views (DRY)

```
app/views/
├── layouts/
│   ├── application.html.erb     # admin web
│   └── public.html.erb           # fluxo do destinatário (mobile)
├── shared/
│   ├── _flash.html.erb
│   ├── _sidebar.html.erb
│   ├── _topbar.html.erb
│   ├── _page_header.html.erb     # título + ações
│   ├── _form_errors.html.erb
│   ├── _status_badge.html.erb    # recebe enum de enumerize, pinta cor
│   ├── _empty_state.html.erb
│   ├── _pagination.html.erb
│   └── _search_form.html.erb
├── addresses/
│   └── _fields.html.erb          # usado em form de Client e Recipient
└── freights/
    ├── _form.html.erb
    ├── _row.html.erb             # linha da tabela (usado em index e dashboard)
    ├── _card.html.erb            # card no dashboard
    └── _qr_panel.html.erb        # painel do QR + código + botões imprimir/compartilhar
```

Regra: **toda página de index herda o mesmo esqueleto** — `shared/page_header` + `shared/search_form` + tabela com `_row` + `shared/pagination`.

---

## Rotas

```ruby
# Admin (autenticado)
namespace :admin do
  root to: 'dashboard#show'
  resources :freights do
    member { get :qr_code; get :print }
  end
  resources :clients
  resources :recipients
  resources :drivers
  resources :reports, only: :index do
    collection { get :monthly; get :monthly_pdf }
  end
  resource :company, only: %i[show edit update]
end

# Público (sem auth, acessado via QR Code)
scope :d, controller: 'public/deliveries' do
  get  ':token',           action: :show,    as: :public_delivery
  get  ':token/photo',     action: :photo,   as: :public_delivery_photo
  post ':token/photo',     action: :upload_photo
  get  ':token/signature', action: :signature
  post ':token/signature', action: :sign
  get  ':token/done',      action: :done
end

devise_for :users
root to: redirect('/admin')
```

---

## Passo a passo de desenvolvimento

### Fase 0 — Setup (1 dia)

1. `rails new expresso -d postgresql --css tailwind`
2. Adicionar gems no `Gemfile`, `bundle install`.
3. Configurar `config/database.yml` (usuário/senha via `.env` + `dotenv-rails`).
4. `rails db:create`.
5. Instalar Devise: `rails g devise:install` → `rails g devise User`.
6. Configurar `config/locales/pt-BR.yml` (+ traduções do Devise, Enumerize, Simple Form).
7. Configurar RSpec, FactoryBot, Capybara.
8. `.rubocop.yml`, `.editorconfig`, `bin/setup`.
9. Commit inicial.

### Fase 1 — Fundação (2 dias)

1. Criar `ApplicationController` com concerns `Authenticatable`, `Authorizable`, `Paginatable`, `Searchable`.
2. Criar `ApplicationRecord` com helpers comuns.
3. Criar `app/models/current.rb` (`CurrentAttributes` para `Current.user`).
4. Criar layout `application.html.erb` com sidebar + topbar (extraídos da imagem do mockup).
5. Partials base: `_flash`, `_sidebar`, `_topbar`, `_page_header`, `_status_badge`, `_empty_state`.
6. Configurar Tailwind com paleta da marca (azul escuro do sidebar, azul primário dos botões).
7. Configurar Pundit (`ApplicationPolicy`).
8. Configurar Active Storage com variants.

### Fase 2 — Modelos base (2 dias)

1. **Concerns primeiro:** `Addressable`, `Codeable`, `Tokenable`, `Auditable`, `Statusable`.
2. Migração + model `Address` (polymorphic).
3. Migração + model `Company` (singleton — `Company.current` via método de classe).
4. Migração + model `Client` (inclui `Addressable`, `Auditable`).
5. Migração + model `Recipient` (inclui `Addressable`, `Auditable`).
6. Migração + model `Driver` (ou role no User via Enumerize).
7. Adicionar enum de `role` em `User` via `enumerize :role, in: %i[admin operator driver], default: :operator, predicates: true, scope: true`.
8. Specs de model para cada um (validações, associações, concerns).

### Fase 3 — Frete + QR Code (3 dias)

1. Migração + model `Freight` com `Codeable`, `Tokenable`, `Auditable`, `Statusable`.
2. Enumerize de `status` (com I18n em `pt-BR.yml`).
3. Job/método para gerar QR Code SVG no `after_create` — URL aponta para `public_delivery_url(token)`.
4. `Admin::FreightsController` (CRUD completo).
5. Form `freights/_form.html.erb` usando Simple Form + partial `addresses/_fields`.
6. Index com Ransack + Pagy + partial `_row`.
7. Show com `_qr_panel` (botões Imprimir/Compartilhar via Web Share API).
8. Action `print` com layout dedicado para impressão.
9. Policy `FreightPolicy`.
10. System specs do fluxo completo.

### Fase 4 — Dashboard (1 dia)

1. `Admin::DashboardController#show` com queries de contagem por status (`Freight.with_status(:pending).count`, etc.).
2. Cards de KPI + tabela "Fretes de Hoje" reutilizando `freights/_row`.
3. Sem duplicar nada — toda informação vem dos mesmos partials da Fase 3.

### Fase 5 — Fluxo público (destinatário) — 4 dias

Esse é o coração do produto. Layout próprio (`public.html.erb`), mobile-first.

1. `Public::DeliveriesController` com `before_action :find_freight_by_token`.
2. `show` — passo 2 do mockup: dados da entrega (cliente, destinatário, endereço, valor, observações).
3. `photo` — passo 3: input `<input type="file" capture="environment">` + preview Stimulus controller.
4. `upload_photo` — anexa via Active Storage, redireciona pra signature.
5. `signature` — passo 4: Stimulus controller usando `signature_pad` (importmap pin). Salva SVG em hidden field.
6. `sign` — cria/atualiza `Delivery` com foto + assinatura + nome do recebedor + IP/UA + `delivered_at`. Transiciona `Freight#status` para `:delivered`.
7. `done` — passo 5: confirmação com data/hora.
8. Token deve ser one-shot? Decidir: permitir reabertura enquanto não entregue; bloquear edição após `delivered`.
9. System specs cobrindo o fluxo inteiro com upload de foto fake.

### Fase 6 — Comprovante PDF (1 dia)

1. `ComprovantePdf` (em `app/pdfs/`) — classe Prawn que recebe um `Freight` e gera o PDF do mockup (dados empresa, frete, foto, assinatura).
2. Action `Admin::Freights#receipt` retorna `send_data pdf.render, type: :pdf`.
3. Link público também — destinatário pode baixar após `done`.

### Fase 7 — Relatório mensal (2 dias)

1. `Admin::ReportsController#monthly` — filtros: cliente, mês/ano.
2. View HTML reproduz tabela do mockup (data, código, destinatário, valor, assinatura inline SVG, thumb da foto).
3. `monthly_pdf` — `RelatorioMensalPdf` (Prawn + prawn-table) gera o PDF.
4. Total calculado no model (`Freight.delivered.in_month(date).for_client(client).sum(:amount)`) — método de classe, não na view.

### Fase 8 — Clientes / Destinatários / Motoristas (1 dia)

CRUDs simples reaproveitando todo o esqueleto criado:
- Index = `page_header` + `search_form` + tabela + `pagination`.
- Form = Simple Form + `addresses/_fields`.
- Show = card de dados + lista de fretes relacionados (reusa `freights/_row`).

### Fase 9 — Configurações (0.5 dia)

- `Admin::CompaniesController#edit/#update` para editar `Company.current` (CNPJ, contato, logo).
- Logo via Active Storage, mostrado no header do PDF e do app público.

### Fase 10 — Polimento (2 dias)

1. **I18n** — varrer views, garantir zero string hardcoded.
2. **Acessibilidade** — labels, aria, contraste.
3. **Performance** — `includes` para evitar N+1 (bullet em dev).
4. **Segurança** — `brakeman`, revisar policies, rate limit nos endpoints públicos (`rack-attack`).
5. **Seeds** — `db/seeds.rb` com dados realistas de demo.
6. **README** com instruções de setup.
7. **CI** — GitHub Actions: rubocop + rspec + brakeman.

---

## Convenções obrigatórias

### Enumerize (sempre)

```ruby
class Freight < ApplicationRecord
  extend Enumerize

  enumerize :status,
            in: %i[pending in_transit delivered cancelled],
            default: :pending,
            predicates: true,   # freight.delivered?
            scope: true         # Freight.with_status(:delivered)
end
```

I18n em `config/locales/pt-BR.yml`:
```yaml
pt-BR:
  enumerize:
    freight:
      status:
        pending: "Pendente"
        in_transit: "Em trânsito"
        delivered: "Entregue"
        cancelled: "Cancelado"
```

Na view, **sempre**:
```erb
<%= render 'shared/status_badge', value: freight.status %>
```

Nunca `case freight.status when ...` na view.

### Partial obrigatório

Qualquer bloco HTML que apareça em 2+ lugares **vira partial** em `app/views/shared/` ou na pasta do recurso. Regra do "rule of two", não "rule of three".

### Concern obrigatório

Qualquer método/callback que apareça em 2+ models vira concern. Concerns ficam em `app/models/concerns/` com nome `Verbavel` (ex: `Addressable`, `Codeable`).

### Service objects

Lógica multi-step (ex: "criar frete + gerar QR + enviar email") vai para `app/services/` como POROs com `.call`.

---

## Checklist de "pronto" para cada feature

- [ ] Model com validações + specs
- [ ] Concern extraído se houver repetição
- [ ] Policy + spec
- [ ] Controller magro + spec de request
- [ ] View usando partials compartilhados
- [ ] Strings em I18n pt-BR
- [ ] Enums via Enumerize com tradução
- [ ] System spec do happy path
- [ ] Rubocop limpo
- [ ] Brakeman sem warnings novos

---

## Próximo passo sugerido

Começar pela **Fase 0** (setup) e ir validando fase a fase. Posso iniciar agora se você confirmar.
