# Expresso Leva e Traz

Sistema web de gestão de fretes com comprovação digital (QR Code + foto + assinatura).

Veja [CLAUDE.md](CLAUDE.md) para o plano completo de desenvolvimento.

## Stack

- Ruby 3.3 · Rails 8.0 · PostgreSQL 17 · TailwindCSS v4 · Hotwire
- Devise (auth) · Pundit (authz) · Enumerize (enums) · rqrcode · Prawn
- RSpec + FactoryBot + Capybara

## Setup local

```bash
bin/setup
```

O script roda `bundle install`, copia `.env.example` para `.env`, cria/migra o banco (dev + test) e prepara tudo.

### Dependências do sistema
- **PostgreSQL 14+** — conexão via peer auth (usuário do sistema)
- **ImageMagick** ou **libvips** — opcional, só pra variants de imagem do Active Storage (`apt install imagemagick`)
- Chrome/Chromium se for rodar system specs com JS

## Rodando

```bash
bin/rails s              # web em :3000
bin/rails tailwindcss:watch    # CSS em modo watch (opcional)
bin/jobs                  # Solid Queue worker (pra background jobs)
```

Ou tudo junto via foreman:
```bash
bin/dev
```

## Seeds

```bash
bin/rails db:seed
```

Cria:
- `admin@expresso.test` / `password123` (perfil admin)
- `motorista@expresso.test` / `password123` (perfil driver)
- 3 clientes, 2 destinatários, alguns fretes pra testar

## Rotas principais

| Rota | Descrição |
|---|---|
| `/admin` | Dashboard com KPIs |
| `/admin/freights` | Lista de fretes (filtros via `?q[...]`) |
| `/admin/freights/:id` | Show com QR Code + comprovante |
| `/admin/freights/:id/receipt` | PDF do comprovante |
| `/admin/reports/monthly` | Relatório mensal por cliente |
| `/admin/company` | Configurações da empresa |
| `/d/:token` | Fluxo público do destinatário (escaneado via QR) |

## Tests

```bash
bin/rspec                                 # toda a suíte
bin/rspec spec/models/freight_spec.rb     # arquivo
bin/rspec spec/models/freight_spec.rb:42  # linha
```

## Qualidade

```bash
bin/rubocop      # estilo (omakase + custom)
bin/brakeman -q  # segurança
```

## Estrutura

```
app/
├── controllers/admin/        # admin (autenticado)
├── controllers/public/       # fluxo do destinatário (sem auth, token)
├── controllers/concerns/     # Authenticatable, Authorizable, Paginatable, Searchable
├── models/concerns/          # HasAddress, Codeable, Tokenable, Statusable, Auditable
├── pdfs/                     # ComprovantePdf, RelatorioMensalPdf
├── policies/                 # Pundit policies por recurso
└── views/shared/             # partials reusáveis (page_header, status_badge, etc.)
```

## Deploy (notas)

- **Railway**: `Dockerfile` já presente; criar 2 services (web + worker `bin/jobs`)
- **Active Storage**: trocar `:local` por Railway Volume / R2 / S3 em produção
- **Master key**: setar `RAILS_MASTER_KEY` no provedor
