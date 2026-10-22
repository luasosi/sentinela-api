---
title: ADR-004 — Persistência direta com EF Core, sem repositório
status: aceita (retroativa)
origem: retroativo
abrangencia: API inteira
created: 2026-10-22
updated: 2026-10-22
---

# ADR-004 — Persistência direta com EF Core, sem repositório

- **Status:** aceita (retroativa). Registrada a partir do código `api` no commit `faa728c` e da política de `api/AGENTS.md`.
- **Abrangência:** API inteira.
- **Relacionadas:** [ADR-003](ADR-003-transacao-por-comando.md), [ADR-005](ADR-005-entidades-como-contrato-json.md), [ADR-006](ADR-006-dois-provedores-de-banco.md). O modelo de dados está no [arquitetura.md §7](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#7-modelo-de-dados).

## Decisão

- Os handlers recebem `ConduitContext` por injeção e consultam os `DbSet` diretamente (`api/src/Conduit/Features/Articles/Create.cs:46`, `:54-101`). Não existe camada de repositório nem unidade de trabalho própria. O `ConduitContext` faz esse papel (`api/src/Conduit/Infrastructure/ConduitContext.cs:16-27`).
- Listas são lidas com `AsNoTracking` e projetadas direto para o DTO de saída (`api/src/Conduit/Features/Articles/List.cs:33`, `:76`).
- Unicidade de `Username`, `Email` e `Slug` fica a cargo do banco, por índice único. A violação é traduzida para 409 num ponto só, o `SaveChangesAsync` sobrescrito (`api/src/Conduit/Infrastructure/ConduitContext.cs:18`, `:171-201`).
- A única abstração de leitura compartilhada é o `IProfileReader`, usado por `Profiles` e `Followers` (`api/src/Conduit/Features/Profiles/IProfileReader.cs:6`, `api/src/Conduit/Features/Profiles/ProfileReader.cs:15`, `api/src/Conduit/Features/Followers/Add.cs:26`).

## Regras que decorrem

- "Persistência só via EF Core com `ConduitContext`; não introduza outra abstração de persistência sem requisito concreto" (`api/AGENTS.md`).
- Regras de unicidade novas devem seguir o mesmo caminho: índice no banco e tradução em `SaveChangesAsync`. Hoje a lista `UniqueFields` é fixa.

## Consequências

- Os handlers ficam acoplados ao EF Core. Os testes de slice usam SQLite real em memória, sem mock de repositório (`api/tests/Conduit.IntegrationTests/SliceFixture.cs:15`, `:25`).
- Uma violação de restrição que não seja de um dos três índices conhecidos continua como erro 500 (`api/src/Conduit/Infrastructure/ConduitContext.cs:183-194`).
