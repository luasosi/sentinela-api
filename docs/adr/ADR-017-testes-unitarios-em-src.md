---
title: ADR-017 — Unitários em src/Conduit.UnitTests e Reqnroll em testes/integracao
status: aceita (não implementada)
origem: etapa 2 do plano (bmad-tea-framework)
abrangencia: testes da API
created: 2026-10-22
updated: 2026-10-22
---

# ADR-017 — Unitários em `src/Conduit.UnitTests` e Reqnroll em `testes/integracao`

- **Status:** aceita; ainda não implementada (ver "Situação da implementação").
- **Abrangência:** projetos de teste da API.
- **Relacionadas:** [ADR-001](ADR-001-vertical-slices-por-feature.md), [ADR-015](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/ADR-015-piramide-de-testes.md) (pirâmide de testes), [ADR-013](https://github.com/luasosi/sentinela-workspace/blob/master/docs/adr/ADR-013-testes-de-integracao-existentes.md) (xUnit existentes).

## Contexto

O ADR-015 define os três níveis de teste, mas não diz onde fica o xUnit unitário novo. A regra do TEA só aceitava código de teste em `api/testes/integracao`. Os xUnit existentes, em `tests/Conduit.IntegrationTests/`, usam banco e por isso contam como integração.

## Decisão

- **Unitário:** um projeto próprio em `src/Conduit.UnitTests/`, ao lado de `src/Conduit/`, com referência a ele. As pastas repetem as do código (`Infrastructure/SlugTests.cs` testa `Infrastructure/Slug.cs`). Esse projeto não pode usar banco, `SliceFixture` nem HTTP.
- **Integração (Reqnroll):** o projeto `testes/integracao/Conduit.Integracao.csproj`, com `Features/<area>/F0N-nome.feature` em Gherkin pt (`# language: pt`), `Steps/` e `Suporte/`. Ele não referencia o projeto da API: chama o HTTP em `SENTINELA_API_URL`, que tem padrão `http://localhost:5050/api`.
- **Execução (a implementar):**
  - O alvo `test` de `build/Program.cs` passa a rodar `tests/**/*.csproj` e `src/**/*.UnitTests.csproj`. Hoje ele roda só `tests/**/*.csproj`. O workflow "Build and Test" já chama o alvo, então não precisa mudar.
  - O Reqnroll terá o alvo próprio `test-integracao`, que exige a API no ar, e o workflow `testes-integracao.yml`. Esse workflow subirá a API no job ou usará `vars.SENTINELA_HOMOLOGACAO_URL`.
- **Nome no código:** o ID do caso vai no nome do teste: `UT_F01_01_...` no xUnit, título `IT-F01-01 · ...` e tags `@IT-F01-01 @CN-01.01 @P0` no Reqnroll.

## Alternativas recusadas

- **Teste no mesmo projeto da API (`src/Conduit/Features/...`).** O xUnit e os testes entrariam no `Conduit.dll` publicado e na imagem Docker. Isso também contraria o ADR-001, que define o que fica numa slice.
- **Unitários em `testes/unitarios/`.** É viável, mas a usuária preferiu manter o unitário perto do código, em `src/`.

## Consequências

- Os dois projetos novos deverão entrar em `Conduit.slnx` e passar pelo mesmo build travado (`packages.lock.json`), pelo formato do CSharpier e pelo warnings-as-errors.
- Um unitário que precisar de banco está no nível errado: ele vai para a integração (Reqnroll ou xUnit existente).
- O Reqnroll não roda no `test`, porque depende de uma API no ar. Depois de implementado, para rodar localmente, suba `subir-api.ps1` e use `dotnet run --project build/build.csproj -- test-integracao`.

## Situação da implementação

Em 2026-10-22 nada desta decisão existe no repositório: não há `src/Conduit.UnitTests/`, `testes/integracao/`, o alvo `test-integracao`, o workflow `testes-integracao.yml` nem entradas no `Conduit.slnx`. A pasta `tests/Conduit.IntegrationTests/` e o alvo `test` seguem como antes. Este ADR registra o destino; atualize esta seção e o status quando os projetos forem criados.
