# 📋 Module Report: Local Market Artisans (Açores)

> **Repositório:** [https://github.com/DavidMatos3434/local_market.git](https://github.com/DavidMatos3434/local_market.git)
> **Análise efetuada:** Agosto 2026 | **Status:** Protótipo funcional — navegação e catálogo operacionais

---

## 1. VISÃO GERAL DO MÓDULO
Módulo piloto da plataforma Local Market Engine, focado no marketplace de artesãos dos Açores. O projeto evoluiu significativamente: passou de uma HomePage estática com lista de artesãos para um marketplace com duas abas, navegação completa via GoRouter, ecrãs de detalhe de artesão e produto, e um conjunto robusto de scripts Python para gestão e limpeza de dados no Odoo.

---

## 2. STACK TÉCNICA — ESTADO ATUAL

| Camada | Tecnologia | Estado | Notas |
| :--- | :--- | :--- | :--- |
| **App Mobile** | Flutter (Dart) | ✅ Funcional | Android 16 (SDK 36), minSdk 24 |
| **Backend / ERP** | Odoo 17.0 Community (Docker) | ✅ Configurado | CORS ativado (`--cors='*'`) |
| **Base de Dados** | PostgreSQL 15 + PostGIS (Docker) | ✅ Ativo | |
| **Addon Odoo** | `local_market_artisans` v1.0 | ✅ Enriquecido | Novos campos produto |
| **Gestão de Estado** | Riverpod `^2.5.1` | ✅ Modelos tipados | 4 providers funcionais |
| **Navegação** | GoRouter `^14.0.0` + BottomNav | ✅ Implementado | 3 rotas: `/`, `/artisan`, `/product` |
| **Cache Offline** | Isar `^3.1.0` | ⚠️ Instalado | Não integrado — zero uso em runtime |
| **Localização** | Flutter l10n (ARB) | ✅ PT + EN | 9 strings + plural |
| **Agente IA** | Ollama (Docker) | ⚠️ Container ativo | Não integrado com a app |
| **TTS / Voz** | — | 🔴 Ausente | `flutter_tts` não instalado |
| **Supabase** | — | 🔴 Ausente | Não iniciado |
| **Stripe / Pagamentos** | — | 🔴 Ausente | Não iniciado |

---

## 3. ESTRUTURA FLUTTER — ATUAL
```
lib/
├── core/
│   ├── constants/
│   │   └── market_data.dart              # 9 ilhas, 3 grupos geo, 12 categorias CADA
│   └── network/
│       ├── odoo_client.dart              # JSON-RPC client — 4 métodos
│       └── odoo_providers.dart           # 4 providers Riverpod tipados
├── features/
│   └── catalog/
│       ├── models/
│       │   ├── artisan.dart              # Modelo mobile
│       │   ├── artisan_web.dart          # Modelo web (sem Isar) ⚠️
│       │   ├── product.dart              # Modelo mobile
│       │   └── product_web.dart          # Modelo web ⚠️
│       └── presentation/
│           ├── artisan_details_screen.dart  # ✅ Ecrã de detalhe artesão
│           └── product_detail_screen.dart   # ✅ Ecrã de detalhe produto
├── l10n/
│   ├── app_en.arb / app_pt.arb
│   └── generated/                        # Auto-gerado
└── main.dart                             # GoRouter + HomePage (2 abas)
```

---

## 4. O QUE ESTÁ IMPLEMENTADO ✅

### Flutter / App
- **Navegação GoRouter** com 3 rotas (`/`, `/artisan`, `/product`) usando `context.push` com `extra` tipado.
- **BottomNavigationBar** com 2 abas: "Artesãos" e "Produtos".
- **HomePage — Aba Artesãos**: Hero banner com contagem real, lista horizontal scrollável e grid de categorias.
- **HomePage — Aba Produtos**: Grelha de 2 colunas com imagem, nome e preço (`allProductsProvider`).
- **ArtisanDetailsScreen**: Foto, biografia e grelha de produtos do artesão.
- **ProductDetailScreen**: Imagem full-width, categoria, preço e descrição.
- **Modelos fortemente tipados** com `fromJson` robusto.
- **Imagens Odoo em base64** funcionais.

### Android / Build
- **SDK 36 / Android 16 (Baklava)** — compileSdk e targetSdk alinhados.
- **Alinhamento 16 KB** — `extractNativeLibs="true"` + `useLegacyPackaging = true`.
- **Hack de env vars Windows** — remoção de `ANDROID_PREFS_ROOT` via reflexão.

### Odoo Addon — `local_market_artisans`
- **Modelos**: `res.partner`, `res.company` e `product.template` enriquecidos com campos geográficos e de materiais.
- **Views XML** configuradas para os 3 modelos.
- **CORS ativo** (`--cors='*'`).

### Scripts Python de Dados
- `sync_artisans.py`: Cria 77 artesãos.
- `sync_products.py`: Upsert de produtos com download de imagens (⚠️ Bug identificado).
- `data_cleanup_artisans.py`: Correção de ilhas e grupos geo via CSV.
- `fix_country_and_sync.py`: Normalização do país para Portugal.

---

## 5. BUGS IDENTIFICADOS 🐛

- **BUG 1 — `sync_products.py`**: Typo na linha 45 (`status_status` em vez de `status_code`) impede a sincronização de imagens.
- **BUG 2 — `x_main_category`**: Campo pedido no `odoo_client.dart` mas inexistente no addon Odoo.
- **BUG 3 — Modelos Redundantes**: Ficheiros `_web.dart` são dead code e causam confusão.
- **BUG 4 — Segurança**: Credenciais (email/pass) expostas em texto claro no repositório.
- **BUG 5 — IP Hardcoded**: `serverIp` fixo dificulta a utilização em diferentes redes.

---

## 6. MELHORIAS PRIORITÁRIAS 🔴

### Imediatas (Fase de Estabilização)
- **6.1**: Corrigir typo em `sync_products.py` e reimportar imagens.
- **6.2**: Adicionar `x_main_category` ao addon Odoo e preencher via script.
- **6.3**: Criar sistema de configuração para externalizar IPs e credenciais.
- **6.4**: Eliminar ficheiros `_web.dart` e consolidar modelos.

### Curto Prazo (Próximas 2 semanas)
- **6.5**: Implementar ação real no botão "Interesse no Artigo" (WhatsApp/Email).
- **6.6**: Adicionar filtros por ilha e categoria na aba de Produtos.
- **6.7**: Integrar verdadeiramente o **Isar** para cache offline.
- **6.8**: Tratar preços a zero ("Preço sob consulta").
- **6.9**: Adicionar `flutter_tts` para suporte a agentes de voz.

---

## 7. DADOS — ESTADO ATUAL

| Ficheiro | Registos | Estado |
| :--- | :--- | :--- |
| `import_artisans.csv` | 77 artesãos | ✅ Importados |
| `import_products_acor.csv` | 5 produtos | ⚠️ Sem imagens (Bug 1) / Preço 0.0 |
| `import_pottery_products.csv` | 5 produtos | ⚠️ Sem imagens (Bug 1) |
| `cada_categories.csv` | 84 categorias | ✅ No Odoo e App |

**Cobertura**: 10 produtos de 2 artesãos. 75 artesãos ainda sem catálogo.

---

## 8. RESUMO EXECUTIVO
O projeto avançou bem na estrutura de Marketplace. As prioridades imediatas focam-se na **integridade dos dados** (imagens e categorias) e na **segurança/configuração**. O próximo grande salto será a integração da **IA (Ollama)** e o suporte **Offline (Isar)** para garantir que a app funciona em qualquer ponto das ilhas.
