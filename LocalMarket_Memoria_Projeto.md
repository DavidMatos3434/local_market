# 🗂️ LocalMarket.ai — Ficheiro de Memória do Projeto

> **Última atualização:** Junho 2026 | **Status:** Protótipo validado (módulo Artesãos Açores)

---

## 1. VISÃO GERAL
LocalMarket.ai é uma franquia tecnológica chave-na-mão que combina hardware edge (NVIDIA Spark Mini PC), software white-label e agentes de IA locais para criar marketplaces regionais operados por 1–2 pessoas.

**Missão:** Valorizar a economia local e os produtores regionais através de tecnologia descentralizada, acessível e operacionalmente quase autónoma.
**Tagline:** "O mercado local, potenciado por inteligência local."

---

## 2. MODELO DE NEGÓCIO

### O que se vende ao Operador (Pack Chave-na-Mão)
| Componente | Descrição |
| :--- | :--- |
| **Hardware** | NVIDIA Spark Mini PC com Gemma 4B/27B pré-configurado |
| **Software** | App mobile multiplataforma (Flutter) + Backend (Supabase) white-label com marca regional |
| **Agentes IA** | Suite de agentes locais instalados e calibrados |
| **Formação** | Onboarding do operador e documentação de operação |

### Estrutura de Receitas
- Venda do Pack Hardware+Software (one-time fee ao operador)
- Royalty/SaaS mensal sobre transações ou subscrição fixa
- Expansão vertical por módulo especializado

---

## 3. A NOVA PROFISSÃO: LOCAL MARKET OPERATOR

### O que faz o Humano (1–2 pessoas)
- Prospeção comercial: visitar artesãos, antiquários, produtores locais
- Criar parcerias de transporte e logística regional
- Aprovação final em tarefas críticas (supervisão)
- Representação local da marca

### O que fazem os Agentes IA
O ecossistema de agentes está organizado em 4 camadas funcionais. Cada agente opera de forma autónoma mas pode escalar para supervisão humana quando necessário.

---

### 🟦 CAMADA 1 — Suporte ao Operador
| Agente | Função | Inputs | Outputs |
| :--- | :--- | :--- | :--- |
| **Agente Assistente do Operador** | Coach e co-piloto do Operador. Responde a dúvidas, sugere ações prioritárias, alerta para anomalias. | Mensagens do Operador, dados do dashboard | Respostas, alertas, sugestões priorizadas |
| **Agente de Relatórios e KPIs** | Gera relatórios automáticos de performance (vendas, artesãos, conversão). | Dados Supabase | Relatório semanal/mensal em PDF ou WhatsApp |
| **Agente de Onboarding de Novos Operadores** | Guia novos Operadores na configuração inicial da plataforma. | Formulário de setup | Checklist guiada, configuração assistida |
| **Agente de Saúde do Sistema** | Monitoriza o Mini PC, o estado dos outros agentes, falhas de sync e alertas técnicos. | Logs do sistema | Alertas proativos, auto-recuperação simples |

---

### 🟩 CAMADA 2 — Relação com Artesãos / Produtores
| Agente | Função | Inputs | Outputs |
| :--- | :--- | :--- | :--- |
| **Agente de Contacto com Artesãos** | Canal principal de comunicação via WhatsApp/SMS. Informa sobre vendas, pedidos, stock, pagamentos. | Eventos do sistema + triggers | Mensagens personalizadas e oportunas |
| **Agente de Onboarding de Artesãos** | Guia o artesão do primeiro contacto ao primeiro produto publicado. Recolhe dados, valida identidade. | Foto + dados básicos | Perfil criado, produto publicado, contrato gerado |
| **Agente de Qualidade de Produto** | Analisa fotos e descrições antes de publicar. Sugere melhorias (ângulo, descrição, preço). | Foto + descrição submetida | Feedback ao artesão + aprovação/rejeição |
| **Agente de Coaching de Vendas** | Acompanha artesãos com baixa performance. Sugere ajustes de preço, sazonalidade, tendências. | Dados de vendas por artesão | Sugestões personalizadas mensais |

---

### 🟨 CAMADA 3 — Experiência do Cliente / Comprador
| Agente | Função | Inputs | Outputs |
| :--- | :--- | :--- | :--- |
| **Agente de Atendimento e Vendas** | Responde em qualquer língua, guia compras, FAQs, processa pagamentos via Stripe. | Mensagens do cliente | Respostas, links de pagamento, confirmações |
| **Agente de Recomendação** | Sugere produtos com base no comportamento, sazonalidade, localização e perfil. | Histórico de navegação + contexto | Lista de produtos recomendados |
| **Agente de Pós-Venda** | Acompanha o cliente após a compra: confirmação, tracking, pedido de review. | Dados da encomenda | Mensagens automáticas de follow-up |
| **Agente de Fidelização** | Gere programa de pontos ou benefícios para compradores recorrentes. | Histórico de compras | Notificações de benefícios, cupões |

---

### 🟥 CAMADA 4 — Backoffice Autónomo
| Agente | Função | Inputs | Outputs |
| :--- | :--- | :--- | :--- |
| **Agente de Contabilidade e Faturação** | Emite faturas automáticas (lei PT), declarações de compra, registo contabilístico. | Dados da transação | Fatura PDF, declaração legal, registo Supabase |
| **Agente de Logística e Envios** | Gera etiquetas, escolhe transportadora, comunica ao artesão, faz tracking. | Morada + peso + prazo | Etiqueta pronta, notificação |
| **Agente de Marketing Regional** | Cria posts automáticos para redes sociais. Dispara campanhas segmentadas. | Catálogo + calendário | Posts prontos, campanhas agendadas |
| **Agente de Compliance e Moderação** | Verifica se produtos cumprem regras, deteta fraudes, sinaliza listagens suspeitas. | Listagens + transações | Aprovação/rejeição automática, alertas |
| **Agente de Tradução e Localização** | Traduz listagens e comunicações para EN, ES, FR, DE, etc. | Conteúdo em PT | Versões traduzidas e adaptadas |

---

### 🔁 ORQUESTRADOR CENTRAL
| Componente | Função |
| :--- | :--- |
| **Agente Orquestrador** | Coordena todos os agentes, gere prioridades, resolve conflitos, escala para humano quando necessário. |

---

## 4. ARQUITETURA TÉCNICA

### Hardware Edge
- **Dispositivo:** NVIDIA Spark Mini PC (Project Digits ou equivalente)
- **Modelo IA Local:** Gemma 4B (operação leve) / Gemma 27B (tarefas complexas)
- **Filosofia:** Processamento local → privacidade, velocidade, independência de cloud

### Stack de Software
| Camada | Tecnologia | Justificação |
| :--- | :--- | :--- |
| **App Mobile** | Flutter (Dart) | Codebase única; SDK Supabase oficial; plugins TTS maduros |
| **Voz / TTS** | `flutter_tts` | TTS nativo do SO — sem custo, sem latência, suporta múltiplas línguas |
| **Backend / BD** | Supabase (PostgreSQL, Auth, Storage, Realtime) | Open-source, self-hostable, Realtime para notificações |
| **Pagamentos** | Stripe | SDK Flutter disponível, suporte PT/EU |
| **Inferência (Pequena)** | llama.cpp | Máxima eficiência em hardware limitado; ideal para agentes sempre ativos |
| **Inferência (Grande)** | vLLM | Alto throughput para tarefas complexas. ⚠️ Validar performance no Spark |
| **Agentes IA** | Python (FastAPI) | Roteamento dinâmico entre modelos 4B e 27B |
| **Orquestração** | CrewAI ou LangGraph | Coordenação multi-agente local |

---

## 5. ESTRUTURA DE NAMING E EXPANSÃO

### Instâncias Regionais (por geografia)
- `localmarket.pt/acores` → **Local Market Açores** ✅ (protótipo ativo)
- `localmarket.pt/alentejo` → Local Market Alentejo
- `localmarket.com/boston` → Local Market Boston

### Verticais Especializados (por nicho)
- **Local Market Artesanato** ✅ (módulo validado)
- **Local Market Relíquias**
- **Local Market AgroFresh**
- **Local Market Gastronomia**

---

## 6. ROADMAP DE DESENVOLVIMENTO

### Fase 1 — CONCLUÍDA ✅
- [x] Conceito validado
- [x] Protótipo módulo Artesãos Açores
- [x] Definição da arquitetura base

### Fase 2 — EM CURSO 🔄
- [ ] Setup projeto Supabase (schema, Auth, Storage, RLS)
- [ ] App Flutter base modular + TTS service
- [ ] Agentes Python core (Onboarding + Atendimento + Faturação)
- [ ] Benchmark llama.cpp vs vLLM no NVIDIA Spark

---

## 7. DIFERENCIAIS COMPETITIVOS
1. **IA totalmente local (edge computing)** — sem latência, privacidade total.
2. **Operação mínima** — 1–2 pessoas gerem um marketplace inteiro.
3. **Foco no genuíno local** — posicionamento oposto a Amazon/Etsy.
4. **Compliance legal automático** — faturação portuguesa integrada.

---
Este ficheiro deve ser atualizado a cada sessão de trabalho relevante.
