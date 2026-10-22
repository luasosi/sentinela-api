---
title: ADR-003 — Uma transação por comando, consultas sem transação
status: aceita (retroativa)
origem: retroativo
abrangencia: API inteira
created: 2026-10-22
updated: 2026-10-22
---

# ADR-003 — Uma transação por comando, consultas sem transação

- **Status:** aceita (retroativa). Registrada a partir do código `api` no commit `faa728c`.
- **Abrangência:** API inteira; nos artigos, F01, F03, F04 e F07 são comandos; F02, F05 e F06 são consultas.
- **Relacionadas:** [ADR-002](ADR-002-validacao-no-pipeline-do-mediator.md), [ADR-004](ADR-004-persistencia-direta-com-ef-core.md), [ADR-006](ADR-006-dois-provedores-de-banco.md). Resumo em [arquitetura.md §6](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#6-transações-e-validação) (RT-9).

## Decisão

- A transação é um comportamento transversal: o `DBContextTransactionPipelineBehavior` é o segundo behavior do Mediator, depois da validação (`api/src/Conduit/ServicesExtensions.cs:75-79`).
- Todo request que **não** implementa o marcador `IReadOnlyRequest` (`api/src/Conduit/Infrastructure/IReadOnlyRequest.cs:3`) roda dentro de uma transação. Ela é aberta antes do handler, confirmada ao fim e desfeita em qualquer exceção (`api/src/Conduit/Infrastructure/DBContextTransactionPipelineBehavior.cs:23-44`).
- Requests com o marcador rodam sem transação. Hoje são as consultas: `Articles.Details` e `Articles.List` (`api/src/Conduit/Features/Articles/Details.cs:14`, `api/src/Conduit/Features/Articles/List.cs:22`), `Comments.List`, `Profiles.Details`, `Tags.List` e `Users.Details`.
- O isolamento depende do provedor: `Serializable` no SQLite e `ReadCommitted` no SQL Server. Uma transação já aberta não é reaberta (`api/src/Conduit/Infrastructure/ConduitContext.cs:111-125`).

## Regras que decorrem

- Uma consulta nova implementa `IReadOnlyRequest`. Sem o marcador, ela roda numa transação desnecessária.
- O handler pode chamar `SaveChangesAsync` mais de uma vez: tudo fica na mesma transação. Exemplo: a criação de tag no meio do `Create` (`api/src/Conduit/Features/Articles/Create.cs:67`, `:101`).
- O handler não abre nem confirma transação por conta própria.

## Consequências

- Atomicidade por caso de uso: um erro no meio do comando desfaz tudo (NFR-1 do [arquitetura.md §8](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#8-requisitos-não-funcionais-observados)).
- O comportamento de concorrência difere entre SQLite e SQL Server por causa do isolamento.
