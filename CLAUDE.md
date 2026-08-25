**2026-08-25 — fixed a real gap the new `compliance_gate.py` paywall-fallback check
found: `UpgradeView.swift` never actually checked `purchases.productLoadFailed`.**
Yesterday's fix (v1.0.5) only added a DEBUG-only branch for the screenshot-capture
case — a real user hitting a genuine StoreKit product-load failure (rare, but
possible: no network, misconfigured product ID, etc.) would still see a permanent
spinner with no way to retry. Added a proper `purchases.productLoadFailed` branch
(real "Unable to load purchase option." text + a "Try Again" button calling
`loadProduct()` again) matching the OAnQuan/Makruk pattern, plus the two new
localization keys (`upgrade.loadFailed`, `upgrade.tryAgain`) in both `en.lproj`/
`zh-Hans.lproj`. Build verified: `xcodegen generate` + Debug simulator build →
**BUILD SUCCEEDED**. Re-ran `compliance_gate.py Klotski --all` — all 7 local checks
now pass. **Code committed only (`3b9950e`) — NOT yet built/archived/uploaded/
submitted.** v1.0.5 (the version carrying yesterday's screenshot-only fix) is already
`READY_FOR_SALE`/live, so shipping this would be a 3rd touch on this app in 24 hours —
holding for the user's explicit go-ahead on whether to ship now or bundle into the
next natural update, since this gap is narrow (rare real-world StoreKit failure, not
visible in any screenshot or App Review path).

# Klotski — Huarong Dao Puzzle

Native SwiftUI iOS app for Klotski (Huarong Dao / 华容道), the classic Chinese
sliding-block puzzle. Bundle `com.quyenngo.klotski`. Built end-to-end 2026-07-18
following the build-gate in Claude's memory (`project_klotski_huarong_dao`) — read
that first for the full history (why this puzzle, the incumbent teardown showing a
mislabeled/miscategorized 776-rating leader, naming/ASO research, and the
ChineseChess Pro Classic cross-sell rationale).

**2026-08-24 (later same day) — vision QA found the v1.0.4 submission's own paywall
screenshot is stale AND the UpgradeView had a separate real bug of its own.**
`screenshots/final/{en,zh-Hans}/04-upgrade.png` predated today's DEBUG isPro fix and
showed "You own Klotski Pro ✓" instead of a buy button — same stale-screenshot class as
BauCua. Recapturing (after adding `simctl erase` + an 8s settle wait to
`capture_shots.py`, same fix as elsewhere) surfaced a second, previously-hidden bug:
unlike OAnQuan/Makruk, `Views/UpgradeView.swift` had **no fallback UI at all** when
`purchases.product` stays nil — it showed a permanent spinner forever (StoreKit
reliably fails to resolve a product under a bare `simctl launch`, a known limitation
across this portfolio), not just a slow-to-resolve one. Added the same DEBUG-only
`isCaptureScreenshotFallback` pattern used in OAnQuan/Makruk to render the real
"Unlock — $2.99" button copy when `KL_CAPTURE == "upgrade"` and product load has
failed. Recaptured and verified both locales now show the correct button.
**Pulled, fixed, and resubmitted per standing user policy** (found post-submit bug →
cancel → fix → resubmit, applies to all apps): canceled the v1.0.4 reviewSubmission
(`86819596-...`, which was already `IN_REVIEW` — Apple still allows pulling it;
`CANCELING`→`COMPLETE` took a bit longer than a plain `WAITING_FOR_REVIEW` cancel),
bumped to **v1.0.5 (build 8)** in `project.yml`, archived/exported/uploaded (Delivery
UUID `e18ac6a4-84af-491f-83b3-3bd5fc8c6f6b`, processed `VALID`), attached to the same
appStoreVersion record (versionString PATCHed 1.0.4→1.0.5), pushed the corrected
screenshots via `asc_push_klotski_screenshots.py`, updated `whatsNew` (both locales),
created a new reviewSubmission `14d54493-d882-48c1-95da-48fc6e8af645` and submitted.
**Verified: WAITING_FOR_REVIEW as v1.0.5.** (The separate pre-existing IAP-never-
approved question from [[project_klotski_iap_readytosubmit_investigation]] is
unaffected by this cycle — not addressed here, still its own follow-up.)

**2026-08-24 — v1.0.4 (build 7), DEBUG bug fix, SUBMITTED.** Found by the new portfolio-wide
`~/asc-tools/compliance_gate.py`: `PurchaseManager.updateEntitlementStatus()`'s DEBUG branch
had a bare `isPro = true` (previously — wrongly — documented in the 2026-08-09 review below
as "intentional"), the same double-gating bug already fixed in SamLoc/Fanorona/Dara/
Surakarta. Fixed with the same capture-mode-exempted pattern: `isPro = KL_CAPTURE != nil &&
KL_CAPTURE != "home" && KL_CAPTURE != "upgrade"`. Verified clean build and the real trial/
locked state now shows correctly on a fresh install (previously invisible in every DEBUG
build/screenshot). The old `UNRESOLVED_ISSUES` reviewSubmission from the original 2026-08-02
5.6 rejection was still blocking new submissions — canceled it (not deleted, per
[[asc-resubmit-after-rejection]]) to free the version, corrected the version record's
long-mismatched `versionString` (was stuck at "1.0.1" vs. the real 1.0.4), attached the new
build, and submitted. **Found a real, separate, pre-existing issue while doing this**: the
Pro IAP (`com.quyenngo.klotski.pro`) is in `READY_TO_SUBMIT` state, meaning it may have
never actually ridden an approved submission — same failure class as the 2026-08-09
IAP-never-submitted incident. Attaching an IAP to a review is web-UI-only (not API-
accessible), so this submission went out without it — **deliberately, per user decision, to
not block the code fix; the IAP purchasability question is a separate follow-up**, see
memory `project_klotski_iap_readytosubmit_investigation`. **SUBMITTED, WAITING_FOR_REVIEW**
— app `6792362495`, version `1.0.4` (id `1c41d617-e5f5-4a6a-84d9-418603b6e051`), build
`7`/`f9a77079-8eb2-452d-a47f-946e39aa6a31` attached, reviewSubmission
`86819596-bb10-40c9-abcd-556f3cac4d80`.

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

## No-permanently-free-tier fix (2026-08-22)

Standing portfolio rule set 2026-08-18 (`feedback_no_permanent_free_tier_trials_only`):
no app may offer any content/mode/feature free forever — only a few free credits, or a
7-day time-limited trial for open-ended-use apps. Klotski was still violating this: the
free/paid split was **Classic + all 4 Easy puzzles free forever, unlimited replays**
(not gated by any clock), with only the 7 Medium + 7 Hard puzzles (14 of 19 total) and
the BFS hint system requiring Pro via a permanent `!purchases.isPro` check in
`HomeView.isLocked(_:)`. (The prior description of this bug as "Hard, 6 excluding
classic" was off by one — it's 7 Hard puzzles, `hard1`–`hard7`, plus Classic itself is
tier `.hard` but was separately exempted by id.) This was the same forever-free-tier
gap already fixed across 19 other apps in the 2026-08-18 rollout; Klotski was missed
because its free content wasn't literally an unlocked "mode," just a permanently-free
puzzle subset, which didn't get caught by the original sweep.

Fixed by porting the exact trial-clock pattern from `SamLoc/Core/PurchaseManager.swift`:
- `Core/PurchaseManager.swift` — added `@Published var trialActive`, `trialDaysRemaining`
  (ceil'd days left, floors at 0), a `firstLaunchDate` UserDefaults-backed 7-day clock,
  `evaluateTrialStatus()` (called from `init()`, additive only — no existing
  purchase/entitlement logic touched), and a computed `hasFullAccess: Bool { isPro ||
  trialActive }` — the one gate every view should read now instead of `isPro` directly.
  Existing installs upgrading from the old build have no stored `firstLaunchDate`, so
  they start a fresh 7-day clock on first launch under this build rather than being
  locked out immediately.
- `Views/HomeView.swift` — `isLocked(_:)` no longer special-cases Classic/Easy by id;
  it's now just `!purchases.hasFullAccess`, so during the trial every tier is unlocked
  and once the trial ends (and isPro is false) every tier locks, Classic and Easy
  included. Added a trial-status banner row under the title (clock icon + "Free trial —
  N day(s) left" while active, tapping through to `UpgradeView`; red lock icon + "trial
  ended" copy once expired).
- `Views/GameView.swift` — hint-button gate changed from `purchases.isPro` to
  `purchases.hasFullAccess` (both the tap action and the lightbulb/lock icon), so hints
  work during the trial too, not just for paid Pro.
- `Views/UpgradeView.swift` — subtitle now reads the normal "unlock the full puzzle set"
  copy while the trial is still running, and trial-specific "your 7-day free trial has
  ended" copy once it's expired. `upgrade.feature1` copy corrected from "14 more
  puzzles" (no longer true — now it's all 19) to "All 19 puzzles, every tier."
- `en.lproj` / `zh-Hans.lproj` `Localizable.strings` — added `home.trial.active`,
  `home.trial.ended`, `upgrade.subtitle.trialEnded` (both locales, hand-written matching
  existing tone, not machine-translated), updated `upgrade.feature1`/`feature2` text to
  match the new all-content-gated reality.
- Verified: `xcodegen generate` + clean `xcodebuild build` for iOS Simulator —
  **0 errors, 0 real warnings** (only the standard benign `appintentsmetadataprocessor`
  tooling note).
- **Not done / deliberately out of scope this pass**: no archive/export/upload, no ASC
  metadata push, no submission — this app is still under the account-level Guideline 5.6
  hold (batch 3, scheduled 2026-08-25) and this was a code-only fix per instruction. The
  next resubmission build (whenever the user gives the go-ahead) should bump
  `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` in `project.yml` to carry this fix, same
  as every other version bump in this file.

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

## Build staged for resubmission (2026-08-13)

Archived, exported, and uploaded a Release build ahead of the staggered resubmission — still
blocked until 2026-08-18 by the Guideline 5.6 account-level hold, this app resubmits
**2026-08-25** (batch 3). Build **1.0.3 (6)** uploaded via
`xcrun altool --upload-app` (Delivery UUID `51cd5142-3b1e-45f1-a5e4-f17fca3dc801`), processed to `VALID` by Apple, and
attached to the existing `REJECTED` appStoreVersion (id `1c41d617-e5f5-4a6a-84d9-418603b6e051`) via a direct
`PATCH appStoreVersions/{id}/relationships/build` API call — independently re-verified via a
follow-up `GET` on the same relationship, not just trusted from the PATCH's 204 response.

**Deliberately NOT done yet** — waiting for the user's explicit go-ahead on this app's
scheduled date, per the staggered resubmission plan:
1. Tick the Pro IAP into this version in the App Store Connect **web UI** — the API has no
   way to do this; it must be done from the version's own page (not the IAP's own page, which
   creates an orphaned draft submission — a mistake this portfolio hit once before).
2. Submit for review.

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
- StoreKit 2 non-consumable IAP `com.quyenngo.klotski.pro` ($2.99). No permanently-free
  tier (fixed 2026-08-22, see that section below): a 7-day trial unlocks everything —
  all 19 puzzles across every tier, plus the hint system. Once the trial ends, everything
  locks (including Classic and the 4 Easy puzzles, which used to stay free forever)
  until Pro is purchased.
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
