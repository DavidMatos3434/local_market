# 📋 Module Report: Local Market Artisans (Açores)

> **Repositório:** [https://github.com/DavidMatos3434/local_market.git](https://github.com/DavidMatos3434/local_market.git)
> **Análise efetuada:** Agosto 2026 | **Status:** Protótipo funcional — navegação e catálogo operacionais

---

## 1. VISÃO GERAL DO MÓDULO
Módulo piloto da plataforma Local Market Engine, focado no marketplace de artesãos dos Açores. O projeto evoluiu significativamente desde a análise anterior: passou de uma HomePage estática com lista de artesãos para um marketplace com duas abas, navegação completa via GoRouter, ecrãs de detalhe de artesão e produto, e um conjunto robusto de scripts Python para gestão e limpeza de dados no Odoo.

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
│       │   ├── artisan.dart              # Modelo mobile (com Isar)
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
- **HomePage — Aba Artesãos**: Hero banner com contagem real de artesãos, lista horizontal scrollável com foto e ilha, grid de categorias CADA.
- **HomePage — Aba Produtos**: Grelha 2 colunas com imagem, nome e preço de todos os produtos do catálogo (`allProductsProvider`).
- **ArtisanDetailsScreen**: Foto do artesão (base64), nome, ilha, secção de biografia, grelha de produtos do artesão com tag de categoria e preço.
- **ProductDetailScreen**: Imagem full-width (350px), categoria, nome, preço, descrição, bottomSheet com botão "Interesse no Artigo" (placeholder).
- **Modelos fortemente tipados** — `Artisan` e `Product` com `fromJson` robusto.
- **4 Providers Riverpod**: `artisansProvider`, `categoriesProvider`, `productsByArtisanProvider(id)`, `allProductsProvider`.
- **Imagens Odoo em base64** — `Image.memory(base64Decode(...))` funcional em artesãos e produtos.
- **Localização dinâmica** — locale do dispositivo passado ao Odoo em cada query.
- **Tema consistente** — azul `#003F87`, dourado `#FFD700`, Montserrat, Material 3.

### Android / Build
- **SDK 36 / Android 16 (Baklava)** — compileSdk e targetSdk alinhados.
- **Alinhamento 16 KB** — `extractNativeLibs="true"` + `useLegacyPackaging = true` no Gradle.
- **Java 17** — sourceCompatibility e jvmTarget alinhados.
- **Hack de env vars Windows** — reflexão em `settings.gradle.kts` para remover `ANDROID_PREFS_ROOT`.
- **HTTP em texto simples** — `android:usesCleartextTraffic="true"` para IP local Odoo.

### Odoo Addon — `local_market_artisans`
- **Modelos**: `res.partner` — `x_is_artisan`, `x_upa`, `x_island` (9 ilhas), `x_geo_group` (3 grupos); `res.company` — `x_island`, `x_geo_group` (espelho do partner); `product.template` — `x_materials` (Many2many tags materiais açorianos), `x_is_regional` (certificação).
- **Views XML** para os 3 modelos.
- **CORS ativo** no comando Odoo (`--cors='*'`).

### Scripts Python de Dados
| Script | Função | Estado |
| :--- | :--- | :--- |
| `sync_artisans.py` | Cria 77 artesãos como `res.company` | ✅ Funcional |
| `sync_products.py` | Upsert inteligente de produtos com download de imagens | ⚠️ Bug linha 45 |
| `data_cleanup_artisans.py` | Corrige ilhas e grupos geo em branco usando CSV como fonte | ✅ Funcional |
| `fix_country_and_sync.py` | Define Portugal como país de todos os artesãos | ✅ Funcional |
| `check_odoo_ids.py` | Diagnóstico — verifica IDs de países no Odoo | ✅ Funcional |

---

## 5. BUGS IDENTIFICADOS 🐛

- **BUG 1 — `sync_products.py` linha 45 — Typo crítico**: `if response.status_status == 200:` deve ser `if response.status_code == 200:`. Impacto: Imagens não são sincronizadas.
- **BUG 2 — `x_main_category` — Campo fantasma**: O `odoo_client.dart` pede `x_main_category`, mas este campo não existe no addon Odoo.
- **BUG 3 — Modelos duplicados `_web.dart`**: Ficheiros `artisan_web.dart` e `product_web.dart` são dead code.
- **BUG 4 — Credenciais expostas**: Email e password em texto claro no repositório.
- **BUG 5 — IP hardcoded**: `serverIp` fixo dificulta a utilização em diferentes redes.

---

## 6. MELHORIAS PRIORITÁRIAS 🔴

### Imediatas (esta semana)
- **6.1** — Corrigir typo em `sync_products.py`.
- **6.2** — Adicionar campo `x_main_category` ao addon Odoo e preencher.
- **6.3** — Externalizar credenciais via `.env` ou `config.dart`.
- **6.4** — Eliminar ficheiros `_web.dart` redundantes.

### Curto Prazo (próximas 2 semanas)
- **6.5** — Botão "Comprar" funcional (WhatsApp/Email).
- **6.6** — Ecrã de catálogo com filtros por ilha e categoria.
- **6.7** — Integrar Isar para cache offline.
- **6.8** — Tratar preços a zero ("Preço sob consulta").
- **6.9** — Adicionar `flutter_tts` para suporte a agentes de voz.

---

## 7. DADOS — ESTADO ATUAL

| Ficheiro | Registos | Estado |
| :--- | :--- | :--- |
| `import_artisans.csv` | 77 artesãos | ✅ Importados |
| `import_companies.csv` | 77 empresas | ✅ Importadas |
| `import_products_acor.csv` | 5 produtos | ⚠️ Preços a 0.00 — imagens sem download |
| `import_pottery_products.csv` | 5 produtos | ⚠️ Imagens sem download |
| `cada_categories.csv` | 84 categorias | ✅ No Odoo e em `market_data.dart` |

**Cobertura**: 10 produtos de 2 artesãos em 77.

---

## 8. RESUMO EXECUTIVO
O projeto avançou bem — saiu de uma HomePage estática para um marketplace navegável com dois ecrãs de detalhe funcionais. A base técnica está correta. As prioridades imediatas são a integridade dos dados e a segurança. O próximo grande salto será a integração da IA (Ollama) e o suporte Offline (Isar).

---
Relatório gerado por análise completa do repositório em Agosto 2026.
