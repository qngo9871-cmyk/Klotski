# Klotski — Huarong Dao Puzzle

Native SwiftUI iOS app for Klotski (Huarong Dao / 华容道), the classic Chinese
sliding-block puzzle. Bundle `com.quyenngo.klotski`. Built end-to-end 2026-07-18
following the build-gate in Claude's memory (`project_klotski_huarong_dao`) — read
that first for the full history (why this puzzle, the incumbent teardown showing a
mislabeled/miscategorized 776-rating leader, naming/ASO research, and the
ChineseChess Pro Classic cross-sell rationale).

**Status (2026-08-12): 🟡 Account-level Guideline 5.6 "Review Suspended" hold —
part of a 19-app burst-submission flag, NOT a per-app bug. Resubmission is
HARD-BLOCKED until 2026-08-18 and scheduled for batch 3 (2026-08-25) per
`app-store-rejections/NOTES.md`. v1.0.3 (build 6) is a second, deeper polish pass
(stale marketing screenshots recaptured to show the 08-09 differentiation feature,
ASO keywords refreshed) — ready for resubmission once Apple lifts the hold and
the batch date arrives, NOT submitted yet.** App id `6792362495`, releaseType
`AFTER_APPROVAL`.
Previously: LIVE since 2026-07-18 (v1.0.0); v1.0.1 fixed the IAP-never-attached
bug below and was WAITING_FOR_REVIEW as of 2026-08-02 when the 5.6 hold hit.

## Pre-resubmission quality review (2026-08-09)

Full local review ahead of the 2026-08-18 resubmission window — no ASC/App Store
Connect access, code/build/git only. Summary: this app was already in genuinely
good shape (unlike some others in the same 19-app wave); review mostly
*confirmed* correctness and added one real differentiation pass rather than
fixing a stub.

- **Build**: `xcodegen generate` + clean Debug build for iOS Simulator —
  **0 warnings, 0 errors**.
- **Puzzle logic independently re-verified, not just trusted from prior claims.**
  Wrote a standalone Python BFS (`Board`/`Solver` ported 1:1, including the
  kind-not-id `stateKey`) and ran it against all 19 baked-in `Puzzle.swift`
  layouts: every puzzle is solvable, and the true BFS-optimal move count
  matches the claimed `minMoves`/"par" for all 19, no mismatches. No overlaps,
  no out-of-bounds start positions. Win detection (`Board.isSolved`) and the
  Swift `Solver` logic read correctly against the model.
- **isPro gating re-checked**: still correctly `@ObservedObject`-based
  everywhere (`GameView`, `HomeView`, `UpgradeView`) — no reintroduction of the
  2026-08-02 bug, no double-gating pattern found. `#if DEBUG isPro = true` is
  intentional (lets Debug builds test Pro features) and is the only DEBUG
  branch touching entitlement state.
- **No TODO/FIXME/placeholder/Lorem-ipsum/dev-only text found** anywhere in
  `Klotski/` (grepped the whole target).
- **Onboarding confirmed real and working**: 4-page first-launch flow
  (`OnboardingView`) plus an always-reachable "Rules" sheet from both Home and
  in-game — walked both via simulator screenshots, both languages.
- **Bilingual localization confirmed real and complete**: `en`/`zh-Hans`
  `.lproj` string tables are in 1:1 key parity, hand-written (not
  machine-translated tells), and every screen was visually walked in both
  languages via simulator screenshots — no untranslated/English-leaking strings
  found in the zh-Hans build.
- **Fixed**: `capture_shots.py` had a stale `APP_DIR = Path("/Users/user/Klotski")`
  hardcoded macOS-account path left over from the pre-mac-mini machine — dev
  tooling only (screenshot capture script), not shipped in the app, but it was
  silently broken on this machine. Now resolves `Path(__file__).resolve().parent`
  so it works regardless of account/home path.
- **Differentiation added (small, scoped — not a redesign)**: the four 1×2
  "vertical" blocks and the 2×1 "horizontal" block previously all rendered with
  the same generic "將" label. Real Huarong Dao sets name these pieces — now
  `BlockView` labels them individually and *stably* by `block.id` (id 1 = 關
  Guan Yu, the traditional exit-guard; ids 2–5 = 張飞/趙云/馬超/黃忠, the four
  generals). This is purely cosmetic — `Board.stateKey` still dedupes by
  `(kind, position)`, so solver/BFS correctness is untouched; verified by
  rebuilding and re-running the independent BFS check above. Added a matching
  "The Pieces" section to `RulesView` (`rules.pieces.title`/`.body`, both
  locales) explaining the naming, tying the mechanic more explicitly to the
  Three Kingdoms story the app already tells.
- **Not changed / left alone**: three small dead Localizable.strings keys
  (`win.next`, `upgrade.locked.title`, `home.completed`) are defined in both
  locales but referenced nowhere in Swift — harmless, left as-is rather than
  risk an unrelated edit during a review pass.
- **Version bump**: `MARKETING_VERSION` 1.0.1 → **1.0.2**, `CURRENT_PROJECT_VERSION`
  4 → **5** (`project.yml`, both the top-level default and the target override).

**Open items / needs owner decision**: none blocking. The only owner-facing
question is timing — this build is ready to archive/upload/submit as soon as
the 2026-08-18 Guideline 5.6 hold lifts; do not submit before then.

## Polish pass (2026-08-12)

Second, deeper pre-resubmission pass (this app resubmits in batch 3, 2026-08-25 per
`app-store-rejections/NOTES.md`). Re-verified the 08-09 findings still hold (onboarding,
localization, isPro gating — all still solid, no code changes needed there) and went
looking for real polish problems rather than re-doing the full code audit.

- **Build**: clean `xcodegen generate` + `xcodebuild build` for iOS Simulator (iPhone 17
  Pro) — **0 errors, 0 real warnings** (only the standard benign
  `appintentsmetadataprocessor` "no AppIntents.framework dependency" tooling note, not a
  code warning).
- **Real bug found + fixed: stale marketing screenshots missing a shipped feature.**
  `screenshots/final/{en,zh-Hans}/*.png` were all dated 2026-07-18, but `RulesView.swift`
  was last changed 2026-08-09 (the differentiation pass that added the "The Pieces"/棋子说明
  section naming the Three Kingdoms generals). The screenshots — including the Rules shot
  specifically meant to sell that differentiation — still showed the pre-08-09 UI: generic
  "將" labels on every vertical block in the gameplay shot, and only 3 Rules sections (Goal/
  Move/Stuck) instead of 4. Same class of bug independently found in Bát Tự this same
  session (stale screenshots missing the zodiac-animal feature). Fixed by re-running
  `capture_shots.py` (real in-app UI, not mockups) against the current build. Verified by
  reading the new PNGs directly, before and after: the regenerated `02-classic.png` now
  shows the individually-named pieces (張/趙/馬/黃 visible on-board), and `05-rules.png`
  / `zh-Hans` `05-rules.png` now include the "The Pieces"/"棋子说明" section in both
  languages. No SwiftUI layout bug found this pass (the Upgrade/paywall screen's vertical
  spacing, which looked sparse at first glance, is actually a normal ZStack-centered modal
  layout with roughly symmetric top/bottom padding — not the top-hugging/dead-gap bug class
  seen in other apps this wave; left alone).
- **ASO/keywords refreshed** (description and promotional text were already strong/
  compelling from the original build — left unchanged): dropped keyword tokens fully
  redundant with the indexed app name/subtitle ("klotski", "huarong dao", "cao cao puzzle",
  "sliding block" — all substrings of "Klotski - Huarong Dao Puzzle" / "Slide the Cao Cao
  Block Out" and therefore already indexed for free) and added non-redundant high-value
  search terms: **en-US** now `sliding puzzle,chinese puzzle,three kingdoms,logic
  puzzle,brain teaser,strategy,offline game` (92/100 chars, was 89/100 of largely redundant
  terms). **zh-Hans** dropped `华容道`/`曹操` (both already in the Chinese app name) and added
  `逻辑游戏,单机游戏,智力游戏`, now `klotski,三国,推箱子,滑块拼图,益智游戏,横刀立马,逻辑游戏,
  单机游戏,智力游戏` (44/100 chars, was 36/100).
- **Pushed live via `~/asc-tools/asc_push_klotski.py`** (safe — app not public, only
  metadata/keyword changes, no submit). Confirmed via `asc_inspect_listing.py` that the
  editable v1.0.1 (REJECTED) localization now shows the new keyword strings for both
  locales.
- **Fixed 3 real bugs found in `asc_push_klotski.py` and `asc_push_klotski_screenshots.py`
  while running them** (pre-existing, unrelated to this app's own code, but were silently
  blocking metadata pushes):
  1. `find_app_info` picked the app's `READY_FOR_DISTRIBUTION` appInfo over its `REJECTED`
     one by iteration order — the former 409s on every attribute PATCH (name/subtitle/
     categories all locked) once a REJECTED version exists; now prioritizes REJECTED-family
     states first.
  2. `find_or_create_version` unconditionally force-renamed whatever editable version it
     found back to `"1.0.0"` — correct only for the very first bootstrap run, but now that
     the app has shipped past 1.0.0 this 409s ("version number has been previously used").
     This script only pushes text metadata; versionString/releaseType are owned by the
     Xcode/`project.yml` build+upload pattern and must never be touched here (also matters
     because `releaseType` must stay `AFTER_APPROVAL`, per the standing ASC rule — the old
     code was silently forcing it to `MANUAL`). Now leaves both alone entirely.
  3. `asc_push_klotski_screenshots.py` had the same stale `/Users/user/Klotski` pre-mac-mini
     path bug as `capture_shots.py` had (fixed 08-09) — never actually fixed here, so the
     screenshot push always silently no-op'd (found 0 files, skipped). Now resolves
     `Path.home() / "Projects" / "Klotski"`, matching every other app's push script.
  Also wrapped the (already-approved, unmodifiable) IAP localization PATCH and the appInfo
  category PATCH in try/except so a legitimate 409 on an already-correct/locked field
  doesn't abort the rest of the push — confirmed both scripts now exit 0 end-to-end.
- **Screenshots re-pushed** via the now-fixed `asc_push_klotski_screenshots.py` — confirmed
  "uploaded"/"order set" for all 5 shots × 2 locales, exit code 0.
- **Version bump**: `MARKETING_VERSION` 1.0.2 → **1.0.3**, `CURRENT_PROJECT_VERSION` 5 →
  **6** (`project.yml`, both the top-level default and target override). Rebuilt clean
  after the bump: BUILD SUCCEEDED, 0 warnings.
- **Not changed**: description/promotional text (already compelling, well-structured, no
  generic filler); onboarding, localization, isPro gating (all re-checked, no regressions
  since 08-09).

**Bug found + fixed 2026-08-02: `klotski.pro` was never actually purchasable.**
Same root cause as Sam Loc (see that app's CLAUDE.md and
`[[feedback_iap_must_ride_with_first_version_submission]]`) — the IAP was
configured but never attached to a review submission, so it sat at
`READY_TO_SUBMIT` since launch while the app itself was `READY_FOR_SALE`.
Fixed by bumping to v1.0.1 (build 4), ticking the IAP into a new draft
submission via the ASC web UI, then attaching the new version via API and
submitting both together — now `WAITING_FOR_REVIEW`.

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
