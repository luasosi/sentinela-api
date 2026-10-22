---
title: ADR-002 — Validação de entrada no pipeline do Mediator
status: aceita (retroativa)
origem: retroativo
abrangencia: API inteira
created: 2026-10-22
updated: 2026-10-22
---

# ADR-002 — Validação de entrada no pipeline do Mediator

- **Status:** aceita (retroativa). Registrada a partir do código `api` no commit `faa728c`.
- **Abrangência:** API inteira; nos artigos, valida F01 e F03.
- **Relacionadas:** [ADR-001](ADR-001-vertical-slices-por-feature.md), [ADR-008](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/ADR-008-formato-unico-de-erro.md). Os formatos de resposta estão no [arquitetura.md §4](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#4-formato-dos-erros).

## Decisão

A validação acontece em duas barreiras, nesta ordem:

1. **Model binding (ASP.NET).** O `ValidatorActionFilter`, registrado globalmente, barra um `ModelState` inválido (JSON malformado, tipo errado) com 422 antes da ação (`api/src/Conduit/Program.cs:55`, `api/src/Conduit/Infrastructure/ValidatorActionFilter.cs:11-29`).
2. **FluentValidation no pipeline do Mediator.**
   - Os validators ficam aninhados na classe do caso de uso (`api/src/Conduit/Features/Articles/Create.cs:28-44`).
   - Eles são registrados por varredura do assembly (`api/src/Conduit/ServicesExtensions.cs:82`).
   - O `ValidationPipelineBehavior` é o **primeiro** behavior do Mediator (`api/src/Conduit/ServicesExtensions.cs:75-79`). Ele roda todos os validators do request e lança `ValidationException` se houver falha (`api/src/Conduit/Infrastructure/ValidationPipelineBehavior.cs:23-33`). O middleware de erro converte essa exceção em 422 ([ADR-008](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/ADR-008-formato-unico-de-erro.md)).

As mensagens vêm das constantes de `api/src/Conduit/Infrastructure/Errors/Constants.cs:5-9` (`can't be blank`, `has already been taken`, etc.).

## Regras que decorrem

- O handler assume uma entrada sintaticamente válida. Só valida o que depende do banco ou do usuário atual (existência, autoria) e, nesses casos, lança `RestException` (`api/src/Conduit/Features/Favorites/Add.cs:38`).
- Como a validação roda antes da transação ([ADR-003](ADR-003-transacao-por-comando.md)), um request inválido não abre transação.

## Consequências

- O 422 tem duas origens com chaves diferentes. No FluentValidation, a chave é normalizada para o último segmento em camelCase. No `ModelState`, ela vai crua ([arquitetura.md §4](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#4-formato-dos-erros)).
- O behavior chama `Validate`, que é síncrono (`api/src/Conduit/Infrastructure/ValidationPipelineBehavior.cs:25`). Regras assíncronas do FluentValidation (`MustAsync`) não são suportadas por este pipeline **(inferido)**.
