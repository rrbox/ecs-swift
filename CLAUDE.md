# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ecs-swift` is a Bevy-inspired Entity Component System (ECS) library in Swift, targeting game development with SpriteKit/SceneKit. Swift tools version 5.9; platforms macOS 10.15+ / iOS 13+. The only external dependency is swift-syntax (for macros).

## Commands

```sh
swift build                              # build all targets
swift test                               # run all tests
swift test --filter ecs-swiftTests       # run one test target
swift test --filter WorldTests           # run one XCTestCase class
swift test --filter WorldTests/testFoo   # run a single test method
```

CI (GitHub Actions on PRs to `main`/`develop`, plus CircleCI) runs `swift package resolve`, `swift build`, `swift test`. Both pin **Xcode 26.3** (GitHub Actions selects it via `xcode-select`), which is required by the swift-testing exit tests. There is no lint configuration.

Tests mix **XCTest and swift-testing**: most existing suites are XCTest, while newer ones (`StartUpTest`, `StateTests`, `UsageTest`, `SparseSetTests`, `StaleEntityHandleTests`, `SamePhaseSpawnDespawnTests`, `RemovedOnInactiveScheduleTests`) use `import Testing` / `@Test`. Cases that assert on `assert`/`precondition` failures are written as swift-testing exit tests (`#expect(processExitsWith:)`). Shared mocks live in `Tests/ecs-swiftTests/Mocks/`, ordering helpers in `Tests/ecs-swiftTests/Common/`.

## Package layout

Three source targets, declared via the `Module` helper structs in `Package.swift`:

- **ECS** (`Sources/ECS/`) — the core library.
- **ECS_Macros** (`Sources/ECS_Macros/`) — compiler plugin used by ECS.
- **PlugIns** (`Sources/PlugIns/`) — one module per plugin (`ECS_Graphic`, `ECS_Keyboard`, `ECS_Mouse`, `ECS_ObjectLink`, `ECS_Scene`, `ECS_Scroll`, `ECS_Touch`), each depending only on ECS. All are exported together as the `PlugIns` library product. Each plugin target has its own test target.

## Core architecture (Sources/ECS/)

### World lifecycle and deferred mutation

`World` (`World/World.swift`) owns entities (`SparseSet<EntityRecordRef>`), the schedules, and `WorldStorageRef` — the central storage hub all subsystems hang off. `World.update()` (`WorldMethods/World+Update.swift`) runs three phases — preUpdate → update → postUpdate — and **applies queued commands after each phase**. This deferred-mutation pattern is the key invariant: structural changes (spawn/despawn/add/remove component) requested during a phase never affect queries within that same phase.

The command flow: systems receive a `Commands` parameter → mutations are queued as `Command`s / `EntityTransaction`s (`Commands/`, `EntityCommands/`) → at phase end, entity transactions are applied, then chunk queues (`ChunkStorageRef.applySpawnedEntityQueue()` / `applyUpdatedEntityQueue()`) propagate changes to every chunk.

A corollary of that ordering: **spawning and despawning the same entity within one phase is unsupported**. The spawn is still sitting in the prespawned queue, so the entity is never visible to any system; `ChunkEntityInterface.despawn(entity:)` asserts on it (`isPrespawned(entity:)`).

### Systems and parameter injection

A system is a plain function whose parameters all conform to `SystemParameter` (`SystemParameter/`). `World.addSystem(schedule, closure)` registers each parameter type (`register(to:)`) and wraps the closure; at execution, each parameter is resolved from `WorldStorageRef` via `getParameter(from:)`. Built-in parameters: `Query`/`Query2...Query10`, `Filtered`, `Commands`, `Resource<T>`, `EventReader<T>`/`EventWriter<T>`, `Removed`.

**All systems must be registered before `setUpWorld()`.** `addSystem` calls `preconditionSystemRegistrationIsAvailable()` (`WorldMethods/World+SetUp.swift`) and traps once `isSetUpCompleted` is true, because a `Query` registered later would not see entities spawned before it. Switch system sets at runtime with states instead.

### Storage: chunks are archetypes

`Chunk` (`Chunk/Chunk.swift`) is the base class for anything that tracks a subset of entities. **Queries themselves are chunks**: `Query<C>` stores a `SparseSet<Ref<C>>` and is notified on spawn/despawn/update, so query iteration is just a dense-set walk with no per-frame matching. `Filtered<Q, F>` wraps a query with `With`/`Without`/`And`/`Or` filters (`FilterdQuery/` — the directory-name typo is tracked in issue #184).

Entity tables are `SparseSet` (`Commons/SparseSet.swift`). `insert` grows the sparse array on demand, so there is no separate `allocate()` step to keep in sync across chunks. Every lookup (`value(forEntity:)`, `update(forEntity:)`, `contains`) bounds-checks the slot and compares the **full entity, generation included**, so a stale handle whose slot was reused reads as absent; `pop` traps on such a handle instead of corrupting the dense array.

### Schedules and states

`Schedule` (`Schedule/`) identifies when systems run: `.startUp`, `.update`, pre/post variants, `.removed`, `.customSchedule(...)`, and state-associated schedules (`.didEnter`, `.willExit`, `.onUpdate`, `.onInactiveUpdate`, `.onStackUpdate`, `.onPause`, `.onResume`). The state machine (`States/`) supports `enter` (replace), `push`/`pop` (stack with pause/resume); during preUpdate, state transitions activate/deactivate their associated schedules for the update phase.

The transition step drains one queue per transition kind (`removedOnEnter…` / `removedOnStack…` / `removedOnInactive…`, each with a new-state and a previous-state variant) and mirrors them into `stateSchedulesManager.removedSchedules` (`WorldMethods/World+Update.swift`). Each queue must be consumed exactly once — reusing the wrong one leaves a resumed state's `removedOnInactive` schedules permanently registered (issue #169).

### Events

`EventWriter<T>.send()` queues into an `EventQueue<T>` registered via `World.addEventStreamer(eventType:)`; `EventReader<T>` consumes them, and queues are cleared at frame boundaries (`Event/`). Built-in events: `Spawned` and `Removed` (despawned entities).

### Macros (Sources/ECS_Macros/)

- `@Bundle` — generates `BundleProtocol` conformance for a struct of components.
- `#Query(N)` / `#System(N)` / `#addSystemForWorld(N)` — generate the `Query2...Query10` / `System2...System15` classes and matching `World.addSystem` overloads. The generated variants live in the ECS target as macro expansion sites (e.g. `Query/MultiParamatersQuery.swift`); changing arity limits means touching both the macro and the expansion sites.

### Plugin pattern

A plugin is simply a `(World) -> ()` function applied via `world.addPlugIn(_:)`. The typical plugin (see `Sources/PlugIns/Mouse/`) registers event streamers and extends `World` with methods that forward platform events (NSEvent, touches, etc.) into the ECS event system. `ECS_Scene` provides an `SKScene` subclass that drives `World.setUpWorld()` / `World.update(currentTime:)`.

## Conventions

- assertion/precondition messages are written in English; doc comments are written in Japanese.
