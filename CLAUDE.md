# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

HealthView is a SwiftUI iOS app (single target, bundle id `chasrleslogic.com.HealthView`, iOS 26.5 deployment target, Swift 5) that reads — never writes — Apple Health data via HealthKit and presents it: workouts with route maps, heart-rate graphs, elevation profiles, and pace/splits. It's an early-stage hobby project, similar in spirit to HealthFit, expected to grow into other areas (e.g. all-day heart-rate analysis) over time.

The project has no Info.plist file (`GENERATE_INFOPLIST_FILE = YES`); usage-description strings and other Info.plist keys live in `project.pbxproj` as `INFOPLIST_KEY_*` build settings.

## Commands

**Build (compile check, matches CI in `.github/workflows/build.yml`):**
```
xcodebuild build -project HealthView/HealthView.xcodeproj -target HealthView -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO
```

**Run / manual test:** Open `HealthView/HealthView.xcodeproj` in Xcode and run on a **physical iPhone** (with a paired Apple Watch for real workout data). The user does this step themselves after Claude makes changes.

There is no test target, no lint configuration, and no package manager — this is a plain single-target Xcode project using Xcode 15+ "file system synchronized groups" (`PBXFileSystemSynchronizedRootGroup`). New `.swift` files dropped anywhere under `HealthView/HealthView/` are picked up by Xcode automatically — **no manual `project.pbxproj` edits are needed when adding source files**. `project.pbxproj` only needs editing for build-setting changes (e.g. `INFOPLIST_KEY_*` strings).

### HealthKit can't be tested in the simulator

The iOS Simulator's Health store has no real data, no Watch-synced workouts, and no GPS routes — HealthKit auth/queries behave inconsistently there. Always assume verification happens on the user's physical device, and design features so they degrade gracefully when data is missing (see `WorkoutDetailView`'s handling of workouts with no route/distance).

### HealthKit capability changes require Xcode UI

Adding/changing HealthKit entitlements is more reliable done by the user via Xcode's target → **Signing & Capabilities** → **+ Capability** than by hand-editing `project.pbxproj`/`.entitlements` — Xcode auto-generates and wires these correctly and may overwrite hand-made edits. If a feature needs a new HealthKit data type, request read access in `HealthKitManager.readTypes` and tell the user whether any Xcode-side capability change is needed.

## Architecture

**Read-only by design.** `HealthKitManager` (`HealthView/HealthKit/HealthKitManager.swift`) requests *read* access only (`healthStore.requestAuthorization(toShare: [], read: readTypes)`). Don't add write/share access without an explicit reason — this is a core product decision, not an oversight.

**Data flow:** `HealthKitManager` → plain Swift model structs → SwiftUI views. The manager is `@Observable`, holds the single `HKHealthStore`, and is injected app-wide via `.environment(healthKitManager)` in `HealthViewApp`. It exposes async methods (`fetchWorkouts`, `fetchHeartRateSamples`, `fetchRoute`) that return lightweight wrapper structs — `WorkoutSummary`, `HeartRateSample`, `RoutePoint`/`Split` — rather than raw `HK*` types, so views never touch HealthKit directly. Follow this pattern for new data: add a fetch method to the manager and a small decoupled model struct in `HealthKit/`.

**Folder layout reflects this split:**
- `HealthView/HealthKit/` — the HealthKit access layer: manager + models + pure-function helpers (e.g. `SplitsCalculator`, `ElevationCalculator`).
- `HealthView/Workouts/` — SwiftUI views for the workouts feature (list, detail, and the chart/map sub-views composed into the detail screen).

**Auth gating happens at the root.** `ContentView` is the authorization gate: it checks `healthKitManager.authState` and shows either a "Connect to Health" prompt or `WorkoutListView`. New top-level features should similarly assume HealthKit access may not yet be granted.

**Navigation** uses `NavigationStack` + `navigationDestination(for:)` keyed on the model type (e.g. `WorkoutSummary: Hashable`), not push-by-reference — keep new model structs `Identifiable & Hashable` (hashed/compared by a stable `id`, not by wrapping `HK*` reference types) if they need to participate in navigation.

**Detail screens compose independent chart/map sub-views** (`HeartRateChartView`, `ElevationChartView`, `RouteMapView`, `SplitsView`) that each take plain model arrays and render with Swift Charts / MapKit, fetched in parallel via `async let` in `WorkoutDetailView.loadDetails()`. Each section only renders when its data is non-empty, and `WorkoutDetailView` explains to the user *why* data may be missing (e.g. the "no distance recorded" footnote) rather than silently omitting it — keep that user-facing-explanation pattern for future gaps.

**Charts scale their Y axis to the data, not from zero** — `chartYScale(domain:)` with a small padding derived from the series' own min/max (see `HeartRateChartView`/`ElevationChartView`). Follow this for any new time-series chart so subtle variation stays visible.

**Cross-view scrubbing is driven by one shared selection state.** `WorkoutDetailView` owns `@State selectedDate: Date?` and passes it by `@Binding` to both charts, which use `.chartXSelection(value:)` for drag-to-scrub and draw their own `RuleMark`/`PointMark` + annotation at the nearest sample. `WorkoutDetailView` separately resolves the nearest `RoutePoint` in time and passes it to `RouteMapView` as `selectedPoint`, which drops a marker — so dragging on either chart moves a marker on the map. Reuse this "one shared selection value, each view resolves its own nearest sample" shape for any future linked views.

**Summary stats render as a card grid.** `WorkoutDetailView.stats` builds an array of small `Stat` (icon/title/value) structs — appending an entry only when its underlying data is available — and lays them out via the reusable `StatCardView` in a 2-column `LazyVGrid`. Add new summary metrics by extending that array rather than hand-laying-out more `HStack`s/`Text` pairs.

**Pagination:** `WorkoutListView` fetches in pages (`fetchLimit` growing by `pageSize`) and re-queries from scratch each time rather than tracking offsets/anchors — simplest correct approach for a local, fast HealthKit store. Follow the same approach for any other paginated HealthKit list.
