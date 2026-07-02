# 📋 Module Report: Local Market Artisans (Açores)

> **Repositório:** [https://github.com/DavidMatos3434/local_market.git](https://github.com/DavidMatos3434/local_market.git)  
> **Análise efetuada:** Julho 2026 | **Status:** Protótipo em desenvolvimento ativo

---

## 1. VISÃO GERAL DO MÓDULO

Este é o **módulo piloto da plataforma Local Market Engine**, focado no marketplace de artesãos dos Açores. Os dados de artesãos foram recolhidos do **CADA — Centro de Apoio e Design dos Açores** (Secretaria Regional da Juventude dos Açores), e o backend assenta num **Odoo 17.0 com addon personalizado**, servido via Docker. A app mobile é **Flutter**, com suporte multilíngue (PT/EN) desde o início.

---

## 2. STACK TÉCNICA IMPLEMENTADA

| Camada | Tecnologia | Estado |
|---|---|---|
| **App Mobile** | Flutter (Dart) — Android, iOS, Web, Windows | ✅ Scaffolded |
| **Backend / ERP** | Odoo 17.0 (Docker) | ✅ Configurado |
| **Base de Dados** | PostgreSQL via PostGIS 15 (Docker) | ✅ Ativo |
| **Addon Odoo Customizado** | `local_market_artisans` (Python) | ✅ Implementado |
| **Gestão de Estado** | Riverpod (`flutter_riverpod ^2.5.1`) | ✅ Implementado |
| **Navegação** | GoRouter (`go_router ^14.0.0`) | ✅ Instalado |
| **HTTP Client** | Dio + http | ✅ Implementado |
| **Cache Offline** | Isar DB (`isar ^3.1.0`) | ✅ Instalado (não integrado ainda) |
| **UI** | Material 3 + Google Fonts (Montserrat) | ✅ Implementado |
| **Internacionalização** | Flutter l10n (ARB files) — PT + EN | ✅ Implementado |
| **Agente IA** | Ollama (Docker, porta 11434) | ⚠️ Container declarado |
| **Sync Script** | Python (`sync_artisans.py`, `sync_products.py`) | ✅ Funcional |

---

## 3. ESTRUTURA DO PROJETO FLUTTER

```
lib/
├── core/
│   ├── constants/
│   │   └── market_data.dart          # Dados estáticos: ilhas, grupos geo, categorias CADA
│   └── network/
│       ├── odoo_client.dart          # Cliente JSON-RPC para Odoo
│       └── odoo_providers.dart       # Providers Riverpod (artisansProvider, localeProvider)
├── features/
│   └── catalog/
│       ├── models/
│       │   ├── artisan.dart          # Modelo de dados Artesão
│       │   └── product.dart          # Modelo de dados Produto
│       └── presentation/
│           ├── artisan_details_screen.dart
│           └── product_detail_screen.dart
├── l10n/
│   ├── generated/                    # Ficheiros gerados automaticamente
│   ├── app_en.arb                    # Strings em Inglês
│   └── app_pt.arb                    # Strings em Português
└── main.dart                         # Entry point + HomePage + Router
```

---

## 4. ADDON ODOO — `local_market_artisans`

### Localização
`custom_addons/local_market_artisans/`

### Campos Custom implementados (em `res.partner` e `res.company`)

| Campo | Tipo | Descrição |
|---|---|---|
| `x_is_artisan` | Boolean | Identifica se o contacto é um artesão |
| `x_upa` | Char | Número da Carta UPA |
| `x_island` | Selection | Lista das 9 ilhas dos Açores |
| `x_geo_group` | Selection | Ocidental, Central ou Oriental |

---

## 5. DADOS DE ARTESÃOS — CADA

### Dados importados/sincronizados
- **76 Empresas/Artesãos** criados via API.
- **Categorias CADA** (84 registos) importadas via CSV/Odoo UI.
- **Produtos piloto** (Açorbordados e Olaria) sincronizados via script.

---

## 6. O QUE ESTÁ IMPLEMENTADO ✅

- [x] Projeto Flutter funcional no Galaxy S25 e Windows.
- [x] Comunicação real Flutter ↔ Odoo (78 artesãos listados).
- [x] Suporte Multilingual (PT/EN) completo com tradução do Odoo.
- [x] Navegação básica entre Home e Perfil do Artesão.

---

## 7. O QUE FALTA IMPLEMENTAR 🔴 (Próximos Passos)

- [ ] **Integração total do Catálogo:** Mostrar produtos reais de todos os 76 artesãos.
- [ ] **Limpeza de Dados:** Corrigir os campos de Ilha nos registos que falharam no script.
- [ ] **Checkout:** Iniciar integração com MedusaJS para carrinho de compras.
- [ ] **Offline Mode:** Implementar o Isar para guardar os dados localmente.

---
*Relatório consolidado e verificado pelo Agente Local Market OS.*
