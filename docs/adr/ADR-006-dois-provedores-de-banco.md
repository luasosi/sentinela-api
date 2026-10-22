---
title: ADR-006 — Dois provedores de banco com migrations separadas
status: aceita (retroativa)
origem: retroativo
abrangencia: API inteira
created: 2026-10-22
updated: 2026-10-22
---

# ADR-006 — Dois provedores de banco com migrations separadas

- **Status:** aceita (retroativa). Registrada a partir do código `api` no commit `faa728c` e de `api/docs/database-migrations.md`.
- **Abrangência:** API inteira.
- **Relacionadas:** [ADR-003](ADR-003-transacao-por-comando.md), [ADR-004](ADR-004-persistencia-direta-com-ef-core.md), [ADR-014](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/ADR-014-execucao-e-empacotamento.md). As migrations de artigos estão no [arquitetura.md §7](https://github.com/luasosi/sentinela-workspace/blob/master/docs/features/artigos/arquitetura.md#7-modelo-de-dados).

## Decisão

- O provedor é escolhido por configuração: `Database:Provider` (ou `Conduit_DatabaseProvider`), `sqlite` (padrão) ou `sqlserver`. A conexão vem de `ConnectionStrings:Conduit` (`api/src/Conduit/ServicesExtensions.cs:27-68`).
- Há um modelo único em `ConduitContext` e dois contextos derivados, um por provedor, para que cada um tenha o próprio snapshot de migrations (`api/src/Conduit/Infrastructure/SqliteConduitContext.cs:5-7`, `api/src/Conduit/Infrastructure/SqlServerConduitContext.cs:5-6`). As migrations ficam em `Infrastructure/Migrations/Sqlite/` e `Infrastructure/Migrations/SqlServer/`, com fábricas de design-time (`api/src/Conduit/Infrastructure/MigrationContextFactories.cs:6`, `:16`).
- As migrations pendentes são aplicadas na subida da API por padrão. Para desligar, use `Database:ApplyMigrations=false` (`api/src/Conduit/Program.cs:91-96`). A subida recusa um banco criado antes das migrations (`api/src/Conduit/Infrastructure/DatabaseInitializer.cs:16-43`).
- Em produção, o previsto é gerar e revisar scripts por provedor, aplicá-los como passo de implantação e subir com `Database__ApplyMigrations=false` (`api/docs/database-migrations.md:23-36`).

## Regras que decorrem

- Toda mudança de modelo gera migration **nos dois contextos**, com namespace convertido para file-scoped (`api/docs/database-migrations.md:98-108`).
- Uma migration existente nunca é alterada; cria-se uma nova (`api/AGENTS.md`).

## Consequências

- O comportamento varia por provedor: isolamento de transação ([ADR-003](ADR-003-transacao-por-comando.md)) e códigos de violação de unicidade (2067/1555 no SQLite, 2601/2627 no SQL Server) (`api/src/Conduit/Infrastructure/ConduitContext.cs:178-181`).
- Só esses dois provedores existem no código. Qualquer outro banco exigiria um terceiro contexto e um terceiro conjunto de migrations **(inferido)**.
