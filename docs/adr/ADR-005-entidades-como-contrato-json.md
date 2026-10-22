---
title: ADR-005 — Entidades do Domain serializadas como contrato JSON
status: aceita (retroativa)
origem: retroativo
abrangencia: API inteira
created: 2026-10-22
updated: 2026-10-22
---

# ADR-005 — Entidades do Domain serializadas como contrato JSON

- **Status:** aceita (retroativa). Registrada a partir do código `api` no commit `faa728c`.
- **Abrangência:** API inteira; nos artigos, F01, F02, F03 e F07 (item único) e F05 e F06 (lista).
- **Relacionadas:** [ADR-004](ADR-004-persistencia-direta-com-ef-core.md), [ADR-009](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/ADR-009-contrato-http-realworld.md). Os campos estão no [arquitetura.md §5](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#5-serialização).

## Decisão

A mesma classe serve de entidade EF Core e de corpo da resposta:

| Resposta | Modelo serializado | Evidência |
|---|---|---|
| Artigo único | A entidade `Article`, embrulhada em `ArticleEnvelope` | `api/src/Conduit/Features/Articles/ArticleEnvelope.cs:5` |
| Item de lista | DTO de projeção `ArticleSummary` | `api/src/Conduit/Features/Articles/ArticleSummary.cs:7-18` |
| Usuário e perfil | `User` e `Profile`, gerados a partir de `Person` por Mapperly (geração em tempo de compilação) | `api/src/Conduit/Features/ConduitMapper.cs:8-30` |

- Na entidade, campos internos saem do JSON com `[JsonIgnore]` e campos calculados ficam fora do banco com `[NotMapped]` (`api/src/Conduit/Domain/Article.cs:11-42`).
- Opções globais de JSON: nulos explícitos (`api/src/Conduit/Program.cs:57-65`). A exceção é `body`, omitido quando nulo (`api/src/Conduit/Domain/Article.cs:20-22`).
- Datas são gravadas em UTC e voltam com `Z` (`api/src/Conduit/Infrastructure/ConduitContext.cs:38-47`).
- O Mapperly ignora explicitamente `Hash`, `Salt`, `PersonId` e, no perfil, `Email` (`api/src/Conduit/Features/ConduitMapper.cs:11-29`).

## Regras que decorrem

- Mudar uma propriedade pública de `Domain/Article` (nome, tipo, nulidade) muda o contrato HTTP. Essa mudança exige ajustar o front na mesma tarefa (regra "Mudança de contrato" do `AGENTS.md` da raiz).
- Um campo interno novo numa entidade serializada precisa de `[JsonIgnore]`, senão vaza na resposta.

## Consequências

- `Domain` depende de `System.Text.Json.Serialization` e `System.ComponentModel.DataAnnotations.Schema` (`api/src/Conduit/Domain/Article.cs:3`, `:5`).
- `comments` sai sempre como `[]` no artigo único, porque a consulta não carrega comentários ([arquitetura.md §5.1](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#51-artigo-único)).
