# innovare_core (repo lib-innv-core) — Flutter (core/infra)

Pacote compartilhado — provê: **core**. Infra de base dos apps Innovare: camada de rede (`RestContext`/`RestConnect`/`RestOptions`), erros REST, utilitários async, mapper, paginação, storage. Pacote `pkg: innovare_core` (repo é `lib-innv-core`). Base de quase todos os frontends/apps.

## Dev
- Instalar: `flutter pub get`   Testar: `flutter test`   Analisar: `flutter analyze`

## Layout
- `lib/` (network, async, mapper, storage, errors), barrel `lib/innovare_core.dart`.

## Convenções / gotcha conhecido
- App define `class XRestContext extends RestContext` sobrescrevendo `uri()` (base URL). 
- ⚠️ `InnovareCore.Async.network` tem bug de timeout: `_applyTimeout` roda sobre um Future já resolvido (no-op) → não há timeout efetivo. Backends que dependem disso devem aplicar `.timeout()` no cliente HTTP.

## Distribuição
- `publish_to: none`; consumido via git ref (branches como `release/2026-05-19_001`). Vários apps declaram `dependency_overrides` fixando o mesmo ref.

## Dependências internas
- Nenhuma (pacote base).

## Nunca
- Editar `.dart_tool/`, `build/`. Quebrar a API de `RestContext`/`RestConnect` sem alinhar os consumidores (raio de impacto grande → skill `cross-repo-impact`).

## Pronto = `flutter analyze` limpo + `flutter test` verde.
