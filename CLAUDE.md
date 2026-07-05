# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ecs-swift` is a Swift implementation of the Entity Component System (ECS) pattern, heavily influenced by Rust's [Bevy ECS](https://github.com/bevyengine/bevy). It targets game development on top of SpriteKit/SceneKit. Components are defined as plain Swift **structs** conforming to `Component`; the design is protocol-oriented. Source-level docs and comments are written in **Japanese**. (Source: `README.md`)

## Commands

```sh
swift build                      # build all targets
swift test                       # run the full test suite
swift package resolve            # resolve dependencies (swift-syntax)

# Run one test target
swift test --filter ecs-swiftTests
swift test --filter GraphicPlugInTests

# Run a single test type or case (swift-testing / XCTest name)
swift test --filter ecs-swiftTests.QueryTests
```

CI (CircleCI, `.circleci/config.yml`) runs `swift package resolve` → `swift build` → `swift test` on macOS with Xcode 16.4.0. Requires Swift 5.9+ (macOS 10.15+, iOS 13+). (Source: `Package.swift`, `.circleci/config.yml`)

## Module layout

- `Sources/ECS` — the core ECS engine (product: `ECS`).
- `Sources/ECS_Macros` — SwiftSyntax compiler-plugin macros used to code-generate the N-arity variants (see below).
- `Sources/PlugIns/*` — optional plugins, each its own module and product-member of `PlugIns`: `Graphic2D` (ECS_Graphic), `Keyboard`, `Mouse`, `ObjectLink`, `Scene`, `Scroll`, `Touch`. Each plugin depends only on `ECS`.

Every source module has a matching test target under `Tests/` (e.g. `Tests/ecs-swiftTests` tests `ECS`). Tests use the swift-testing framework (`import Testing`, `@Test`) — see `Tests/ecs-swiftTests/UsageTest.swift` for an end-to-end usage example. (Source: `Package.swift`, test files)

## Core architecture

The central object is `World` (`Sources/ECS/World/World.swift`), a class that owns entities and three schedule slots. All engine state lives in `WorldStorageRef` (`Sources/ECS/World/WorldStorageRef.swift`), which holds separate `AnyMap`-backed stores keyed by type: `chunkStorageRef`, `resourceStorage`, `stateStorage`, `systemStorage`, `eventStorage`, `additionalStorage`, plus a shared `commands`. Passing `World` around a game means passing this one storage ref.

**Systems** are just Swift functions. Their parameters must conform to `SystemParameter` (`Sources/ECS/SystemParameter/SystemParameter.swift`), which defines two static hooks: `register(to:)` (called once at `addSystem`) and `getParameter(from:)` (called each execution to resolve the argument from `WorldStorageRef`). To add a new kind of system argument, conform a type to `SystemParameter` — no changes to the executor are needed. Built-in parameters: `Query<C>`, `Commands`, `Resource<R>`, `State<S>`, `EventReader`/`EventWriter`, and custom `AdditionalStorageElement` types.

**Queries** (`Sources/ECS/Query/Query.swift`) are `Chunk` subclasses that maintain a `SparseSet` of component references. They register themselves into `chunkStorageRef` and are kept in sync as entities spawn/despawn/change via `spawn`/`despawn`/`applyCurrentState`. `Filtered<Query, With<...>>` adds filtering (`Sources/ECS/FilterdQuery/`).

**Commands** (`Sources/ECS/Commands/`, `Sources/ECS/EntityCommands/`) are deferred, not immediate. `commands.spawn()` / `commands.entity(_)` / `commands.despawn(_)` enqueue `EntityTransaction`s and `Command`s. They are flushed during `applyCommandsPhase` (spawn queue → apply commands → updated-entity queue), so component structural changes become visible to all queries at frame end. (Source: `Sources/ECS/WorldMethods/World+Update.swift`)

### Update lifecycle

`World.update(currentTime:)` (`Sources/ECS/WorldMethods/World+Update.swift`) runs three phases, each followed by an `applyCommandsPhase`:
1. `preUpdatePhase` — runs `.preUpdate` systems, then processes state-machine transition queues (willExit/onPause/onResume/didEnter, and (de)registers state-associated schedules), then flushes events.
2. `updatePhase` — runs `.update` systems plus systems for currently-active state-associated schedules, then flushes events.
3. `postUpdatePhase` — runs `.postUpdate` systems, then flushes events.

The first frame (`currentTime: 0`) is a preparation frame and does not execute systems. `setUpWorld()` runs the `.preStartUp`/`.startUp`/`.postStartUp` schedules once. (Source: `World+Update.swift`, `Sources/ECS/Schedule/Schedule.swift`)

### Schedules and States

`Schedule` (`Sources/ECS/Schedule/Schedule.swift`) is a type-erased hashable key. Built-ins: `.preStartUp/.startUp/.postStartUp`, `.preUpdate/.update/.postUpdate`, `.removed`, plus `.customSchedule(_)`. **State-associated** schedules (`.didEnter`/`.willExit`/`.onUpdate`/`.onInactiveUpdate`/`.onStackUpdate`/`.onPause`/`.onResume`) are driven by the state machine (`Sources/ECS/States/`), which supports a state stack (push/pop semantics implied by pause/resume/inactive). Register states with `world.addState(initialState:states:)`.

### Events

Event streaming lives in `Sources/ECS/Event/`. Register a type with `world.addEventStreamer(eventType:)`, send with `world.sendEvent(_)`, consume in systems via `EventReader`/`EventWriter`. There is also a lifecycle `Removed` event for despawned components (`Sources/ECS/Event/Removed/`). Events are queued and drained (`applyEventQueue`) after each lifecycle phase.

## Macros (N-arity code generation)

Because Swift lacks variadic generics here, multi-parameter variants are generated by freestanding declaration macros in `Sources/ECS_Macros` (registered in `ECSMacros.swift`):
- `#Query(n)` → `QueryN<C0…Cn>` classes (`Sources/ECS/Query/MultiParamatersQuery.swift`, generates 2–10).
- `#System(n)` → `SystemN` executors and `#addSystemForWorld(n)` → `World.addSystem` overloads (`Sources/ECS/Systems/MultiParametersSystem.swift`, generates 2–15).
- `@Bundle` → generates `BundleProtocol` conformance for grouping components (`Sources/ECS/Commons/Bundle.swift`).

If you need a query/system with more parameters than currently generated, bump the `#Query(n)`/`#System(n)`/`#addSystemForWorld(n)` count in those files rather than hand-writing the type. When touching macro output, remember the generated code is only visible after a build — verify with `swift build`.

## Conventions

- Reference-wrapper types follow a `…Ref` / `Ref<T>` / `Box<T>` naming pattern for the shared-mutable-state boxes threaded through storage.
- Type-erased per-type stores use `AnyMap<StorageType>` keyed by `ObjectIdentifier`; entity/component tables use `SparseSet`.
- Plugins expose their public surface as a free `func somePlugIn(_ world: World)` passed to `world.addPlugIn(_)`, plus `World` extension methods for host integration (e.g. `KeyBoard.swift`'s `keyDown(with:)`). macOS-only plugin code is guarded with `#if os(macOS)`.
