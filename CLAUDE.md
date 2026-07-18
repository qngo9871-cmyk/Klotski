# Klotski — Huarong Dao Puzzle

Native SwiftUI iOS app for Klotski (Huarong Dao / 华容道), the classic Chinese
sliding-block puzzle. Bundle `com.quyenngo.klotski`. Built end-to-end 2026-07-18
following the build-gate in Claude's memory (`project_klotski_huarong_dao`) — read
that first for the full history (why this puzzle, the incumbent teardown showing a
mislabeled/miscategorized 776-rating leader, naming/ASO research, and the
ChineseChess Pro Classic cross-sell rationale).

**Status as of 2026-07-18: built, metadata/scripts ready, blocked on Q's manual
"+ New App" ASC click.** See memory for current state before assuming anything here
is stale.

## What this is

- 4×5 grid, 10 fixed blocks (one 2×2 "Cao Cao" general, one 2×1 horizontal, four
  1×2 vertical, four 1×1 soldier). No rotation — orthogonal single-cell slides only.
- Goal: slide Cao Cao's block to the bottom-center exit (col 1-2, row 3-4).
- **19 puzzles, every one verified solvable by exhaustive BFS at content-authoring
  time** (see `/gen_klotski_puzzles.py` in the scratchpad history, or regenerate
  with the same technique — slice a real optimal solution path at different
  distances-to-goal, don't random-walk-and-hope; a random scramble near the classic
  start is almost always still ~80+ moves from goal, so random walks alone only ever
  produce "hard" puzzles).
- Move counter, undo, per-puzzle best-score tracking (UserDefaults), and a live
  BFS-powered hint button (same solver, off the main thread).
- StoreKit 2 non-consumable IAP `com.quyenngo.klotski.pro` ($2.99) — free tier is
  the Classic + 4 Easy puzzles; Pro unlocks the 7 Medium + 7 Hard puzzles AND the
  hint system for every puzzle including free ones.
- **True bilingual in-app UI** (English + Simplified Chinese) — same
  `LocalizationManager` bundle-swap architecture as the Sâm Lốc app, live in-app
  language switch, hand-written strings both locales (not machine-translated).
- Cross-sell banner on the Home screen linking to ChineseChess Pro Classic
  (`com.quyenngo.chinesechess`, App Store id 6762035708) — same dev account, same
  Three Kingdoms world.

## Structure

- `Klotski/Core/Block.swift`, `Board.swift` — the grid/piece model + move
  validation. **`Board.stateKey` is keyed by (kind, position), NOT block id** — this
  matters, see below.
- `Klotski/Core/Solver.swift` — BFS solver (`Solver.solve`/`Solver.hint`).
- `Klotski/Core/Puzzle.swift` — the 19 baked-in verified puzzle layouts.
- `Klotski/Core/GameModel.swift`, `PurchaseManager.swift`, `Localization.swift`.
- `Klotski/Views/` — `HomeView` (puzzle list by tier), `GameView` (board + tap-to-
  select + directional pad), `BlockView`, `RulesView`, `UpgradeView`.
- `Klotski/{en,zh-Hans}.lproj/Localizable.strings`.
- `capture_shots.py` — real in-app screenshots via `KL_CAPTURE`/`KL_LANG` DEBUG
  launch args, into `screenshots/final/{en,zh-Hans}/`.
- `make_icon.py` — bold single-emblem icon (tilted red "帥" block, matches the
  actual in-app Cao Cao block color).

## Reasoning mode — real bugs already caught here, don't reintroduce them

1. **The state-dedup key MUST be by (kind, position), not by block id.** The four
   soldiers and four vertical blocks are visually/functionally interchangeable.
   Keying the BFS visited-set by id treats every relabeling as a distinct state (up
   to a 24×24 symmetry factor), which explodes the true ~26k-state search space into
   the millions and makes BFS never converge. This was caught by prototyping the
   solver in Python first and finding it "unsolvable" at a 2M-node cap before
   realizing the bug — confirmed the same bug existed in the Swift `Board.stateKey`
   and fixed it there too before it ever shipped.
2. **`PurchaseManager.shared.isPro` must be read through `@ObservedObject`, not a
   bare static reference.** `isPro` flips asynchronously after first render (the
   entitlement check in `PurchaseManager.init()`), and a view that reads
   `PurchaseManager.shared.isPro` directly (not via `@ObservedObject`/`@StateObject`)
   never re-renders when it changes — the Hint button showed a permanent lock icon
   in `#if DEBUG` builds despite `isPro` actually being `true`. Caught by visually
   inspecting a screenshot, not by the build succeeding. `GameView` now holds
   `@ObservedObject private var purchases = PurchaseManager.shared`; any new view
   that reads Pro status needs the same pattern.
3. **English `%@`-template strings must stay grammatically valid for both "You" and
   a third-person name** if any UI ever names the human player generically (this
   app doesn't currently, since it's single-player against no AI opponent — but if
   a future version adds named challenges/leaderboards, re-check every `%@ wins`/
   `%@ leads`-style string; this exact bug shipped once in the Sâm Lốc app this same
   week, see that repo's CLAUDE.md).
4. When generating puzzle content for a sliding-block puzzle, **grade difficulty by
   slicing a real BFS-optimal solution path at different distances-to-goal — never
   by random-walk length from an arbitrary start.** A random walk of any length near
   the classic starting layout almost always lands far from the goal (CLASSIC itself
   is 87 moves from solved), so random-walk generation only ever produces "hard"
   puzzles no matter how short the walk. Verified/fixed during this build — see the
   generator script history if you need to add more puzzles later.

## Deploy / resubmit pattern

Sideload to Q's device (`F8EF55D6-E237-574F-8AB8-EF8EB0693D45`):
```
xcodebuild -project Klotski.xcodeproj -scheme Klotski -destination 'generic/platform=iOS' -configuration Debug build
xcrun devicectl device install app --device F8EF55D6-E237-574F-8AB8-EF8EB0693D45 <path-to-.app>
```

App Store archive/upload (distribution profile already exists after the first
export — the `-authenticationKey*` flags were only needed once):
```
xcodebuild -project Klotski.xcodeproj -scheme Klotski -configuration Release -archivePath build/Klotski.xcarchive -destination 'generic/platform=iOS' -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath build/Klotski.xcarchive -exportPath build/export -exportOptionsPlist ExportOptions.plist -allowProvisioningUpdates
xcrun altool --upload-app --type ios -f build/export/Klotski.ipa --apiKey G85WXB4AF5 --apiIssuer 2e969722-fc4d-444c-af74-7e0233efd016
```

ASC metadata/IAP/pricing/review-info/screenshots are all scripted and idempotent:
- `~/asc-tools/asc_push_klotski.py`
- `~/asc-tools/asc_push_klotski_review.py`
- `~/asc-tools/asc_push_klotski_screenshots.py`
- `~/asc-tools/asc_upload_klotski_iap_screenshot.py`

Bundle-ID registration (already run, one-time): `~/asc-tools/asc_register_klotski.py`
(id P2TY6AVB65).
