# ADRs da API

Decisões que valem só para a API. As que valem para API e front (autenticação, formato de erro, contrato HTTP, build, testes, execução) ficam no repositório `sentinela-workspace`, em [`docs/adr/`](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/README.md), que também guarda o **próximo número livre** (a numeração é única no sistema).

Leia só este índice; abra um ADR quando ele for citado ou quando a tarefa tocar a regra dele.

| ADR | Decisão | Status | Regra principal para quem constrói |
|---|---|---|---|
| [ADR-001](ADR-001-vertical-slices-por-feature.md) | Vertical slices por feature | aceita (retroativa) | Caso de uso = um arquivo em `Features/<F>/` com request, validators e handler; controller fino; `Domain` não depende de nada; `Infrastructure` não depende de `Features` |
| [ADR-002](ADR-002-validacao-no-pipeline-do-mediator.md) | Validação no pipeline do Mediator | aceita (retroativa) | Validação de entrada em FluentValidation aninhado no caso de uso; o handler só valida o que depende do banco |
| [ADR-003](ADR-003-transacao-por-comando.md) | Uma transação por comando | aceita (retroativa) | Consulta implementa `IReadOnlyRequest`; handler não controla transação |
| [ADR-004](ADR-004-persistencia-direta-com-ef-core.md) | Persistência direta com EF Core | aceita (retroativa) | Handler usa `ConduitContext`; sem repositório; unicidade por índice e tradução para 409 |
| [ADR-005](ADR-005-entidades-como-contrato-json.md) | Entidades como contrato JSON | aceita (retroativa) | Mudar propriedade pública de entidade muda o contrato com o front; campo interno precisa de `[JsonIgnore]` |
| [ADR-006](ADR-006-dois-provedores-de-banco.md) | Dois provedores de banco | aceita (retroativa) | Mudança de modelo gera migration nos dois contextos; nunca alterar migration existente |
| [ADR-017](ADR-017-testes-unitarios-em-src.md) | Unitários em `src/Conduit.UnitTests`, Reqnroll em `testes/integracao` | aceita (não implementada) | Unitário sem banco em `src/Conduit.UnitTests/` (roda no alvo `test`); Reqnroll caixa-preta por HTTP em `SENTINELA_API_URL` (alvo `test-integracao`); ID do caso no nome do teste |
