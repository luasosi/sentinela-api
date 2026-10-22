<!-- bmad:context -->
<!-- Verificado em 2026-10-21 contra 8aa617a. Gerenciado por bmad-project-context; edições dentro deste bloco são substituídas no refresh. Mantenha fora dos marcadores o que quiser preservar. -->

## sentinela-api

API do Sentinela (plataforma de denúncias), fork do Conduit/RealWorld em ASP.NET Core 10 com vertical slices por feature (Mediator, FluentValidation, EF Core com SQLite e SQL Server). O contrato segue a spec RealWorld. O planejamento fica em `../plano/`, fora deste repositório (só existe no layout local).

## Política

- Nunca commite direto em `master`; crie uma branch por etapa de estudo (ex.: `etapa-1/laboratorio`) e abra PR para `master`.
- Mensagens de commit em Conventional Commits, em português (`feat: ...`, `fix: ...`, `test: ...`, `chore: ...`).
- Nunca altere migrations existentes em `src/Conduit/Infrastructure/Migrations/`; crie uma nova.
- Não mexa na autenticação (JWT e hashing de senha, em `src/Conduit/Infrastructure/Security/`) sem pedido explícito.
- Não edite o submódulo `realworld/` (spec upstream vendorizada), a menos que a tarefa seja explicitamente sobre ele.
- Não commite saída de build, bancos SQLite locais, `.jwt-signing-key` nem outros segredos.

## Onde ficam as coisas

- App: `src/Conduit/`; cada feature em `Features/<Feature>/`, com command/query, validator, handler e modelos juntos.
- Testes: `tests/Conduit.IntegrationTests/` em xUnit — slices com SQLite em memória (`SliceFixture`), HTTP com `WebApplicationFactory` (`ApiFactory`); testes focados de autenticação usam EF Core InMemory.
- Alvos de build Bullseye usados pelo CI: `build/Program.cs`.
- Mudando o modelo compartilhado? Leia `docs/database-migrations.md` antes, inclusive para baseline de bancos existentes.

## Rodar e verificar

- SDK do `global.json` (`10.0.402`, roll-forward `latestFeature`), target `net10.0`.
- Depois de mudar código: `dotnet run --project build/build.csproj -- test` — formata com CSharpier (reescreve arquivos), compila em Release e roda todos os projetos de teste. Só formatar: `-- format`. Pipeline completo do CI, com publish: sem argumentos.
- O CI roda `dotnet restore Conduit.slnx --locked-mode` e o build com `--check-format`, que falha em arquivo não formatado em vez de reescrevê-lo.
- Subir localmente no Windows: `.\subir-api.ps1` (sem `make`) — gera/reaproveita `.jwt-signing-key`, usa `conduit-local.db` e serve em `http://localhost:5050` (API em `/api`, Swagger em `/swagger`). Em macOS/Linux: `make run-local`.
- Suítes da spec RealWorld (Hurl/Bruno) exigem `make`, bash e `git submodule update --init realworld`; no Windows sem `make`, deixe-as para o workflow "RealWorld API Tests" do CI.

## Convenções que diferem do padrão

- Versões de pacote só em `Directory.Packages.props`; nunca `Version=` no `PackageReference`.
- Ao mudar dependências, rode `dotnet restore Conduit.slnx` e commite os `packages.lock.json` atualizados; o build usa restore travado.
- Trate todo warning como erro: `Directory.Build.props` liga nullable, analyzers recomendados, code style no build e warnings-as-errors.
- Use file-scoped namespaces e `using System` ordenados primeiro; o build não verifica isso.
- Controllers finos; passe o `CancellationToken` da requisição até handlers e chamadas ao banco.
- Valide requests com FluentValidation, preservando o formato de resposta de erro existente.
- Persistência só via EF Core com `ConduitContext`; não introduza outra abstração de persistência sem requisito concreto.
- Ao mudar o modelo, gere migrations para `SqliteConduitContext` e `SqlServerConduitContext` e converta o namespace gerado para file-scoped antes de compilar.
- Mudança de comportamento exige teste de integração novo ou atualizado, principalmente no contrato da API RealWorld.

## Armadilhas conhecidas

- No Windows PowerShell 5.1, `[Security.Cryptography.RandomNumberGenerator]::GetBytes(32)` não existe; use `[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($buffer)`.

<!-- /bmad:context -->
