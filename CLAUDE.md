# Vocab Quest - K-Pop Themed Vocabulary Game

## Project Overview
A single-file interactive HTML vocabulary game (`vocab-quest.html`) built for an 11-year-old girl and her classmates. The game turns vocabulary study into a K-pop/Gen Z themed adventure through "The Lost Library" with a gacha item shop and customizable SVG wizard avatar. Hosted on GitHub Pages for class-wide access.

## Key Files
- `vocab-quest.html` — The entire game (HTML + CSS + JS in one file, ~4300 lines)
- `index.html` — Copy of vocab-quest.html on gh-pages branch (what GitHub Pages serves)
- `wizard-preview-v3.html` — SVG wizard avatar preview (approved design, integrated into game)
- `wizard-preview-v2.html` — Earlier SVG prototype (reference only)
- `wizard-preview.html` — First SVG prototype (reference only)
- `teach-data.js` — Generated Teach It Back data (already integrated into vocab-quest.html)
- `deploy.bat` / `deploy.sh` — Deploy scripts (merge tweaks → gh-pages, push)

## Git Info
- **Branch `master`**: Merged with tweaks, current stable
- **Branch `master2`**: Old checkpoint — Phases 1-5 complete
- **Branch `master3`**: Checkpoint — SVG variety, chapter groups, redo round, study guide
- **Branch `tweaks`** (CURRENT): Active development branch
- **Branch `gh-pages`**: GitHub Pages deployment branch. **IMPORTANT**: After merging tweaks into gh-pages, you MUST also copy vocab-quest.html to index.html and commit, because GitHub Pages serves index.html
- Always work on `tweaks` branch. Create a new checkpoint branch (master4, etc.) when user wants to save a version.

## Deployment
- **Live URL**: https://demerson-code.github.io/vocab-quest/
- **GitHub repo**: https://github.com/demerson-code/vocab-quest.git
- **Deploy process**:
  1. `git checkout gh-pages`
  2. `git merge tweaks`
  3. `cp vocab-quest.html index.html`
  4. `git add index.html && git commit -m "Sync index.html"`
  5. `git push origin gh-pages`
  6. `git checkout tweaks`
- Or use `deploy.bat` / `deploy.sh` scripts

## Architecture & Structure (inside vocab-quest.html)
The file is organized in this order:
1. **CSS** — All styles including dark theme, animations, responsive design, gacha card effects by rarity, matching game grid, learning card overlay, mastery tracker
2. **HTML** — Screens: `startScreen`, `gameScreen`, `sumScreen`, `shopScreen` + gacha result overlay + parent panel + study guide panel + learning card overlay
3. **JavaScript** — Data objects first, then state, then persistence, then game logic, then gacha/shop logic

### Key JavaScript sections:
- `VOCAB` object — All vocabulary data, keyed by chapter number (7-18). Each entry: `{word, pos, def}`
- `SENTENCES` object — Correct sentence examples per word (uses `___WORD___` placeholder)
- `WRONG_SENTENCES` object — Tricky wrong sentences per word (variety of misuse types, NOT just opposites). Defined inline inside the sentence challenge render function.
- `BOOK_QUOTES` object — 72 Anne of Green Gables-style context sentences, one per word. Shown in Study Guide and occasionally in correct-answer feedback.
- `TEACH_HINTS` object — Per-word teach hints: `{best, vague, wrong}` for Teach It Back round
- `TEACH_SENTENCES` object — Per-word teach sentences: `{best, awkward, wrong}` for Teach It Back round
- `PRAISE` / `ENCOURAGE` arrays — K-pop/Gen Z themed feedback messages
- `ROUND_INFO` array — Round metadata, titles, story text (5 rounds, index 0-4)
- `GACHA_ITEMS` — 48 items across 3 categories (hats/pets/outfits), each with `{id, name, emoji, rarity, power, powerTier, set, desc}`
- `POWER_SCALES` — Lookup table for scaled power values by tier (1-4)
- `SET_BONUSES` — 5 themed sets (Ocean, Space, K-pop, Royal, Nature) with bonus powers
- `PULL_ODDS` — Gacha pull probabilities per tier (basic/super/mega/divine)
- `PULL_COST` — Pull costs: basic=40, super=100, mega=250, divine=500
- `DUPE_REFUND` — Dupe refunds: common=3, rare=8, epic=20, legendary=40, mythic=80
- `ITEM_SVG_MAP` — Maps all 48 gacha item IDs to SVG render parameters `{svgType, headphones, robeHue, hatColor}`
- `S` (State object) — All game state (score, round, hearts, streak, word stats, inventory, equipped, pityCounter, badgeProgress, etc.)
- `SAVE_KEY` / `saveProgress()` / `loadProgress()` / `resetProgress()` — localStorage persistence
- `getChapterMultiplier()` — Returns 0.8x-1.6x based on chapters selected
- `buildChapters()` — Generates chapter checkboxes with week grouping
- `startGame()` — Reads selected chapters + round, initializes state, calls `buildRound()`
- `buildWizard(opts)` — SVG character renderer with configurable hat/outfit/pet/headphones
- `getWizardSvgOpts(suffix)` — Reads equipped items from ITEM_SVG_MAP, returns SVG render options
- `renderMatchingGame()` — Matching grid renderer with batch processing (Round 0)
- `processAnswer()` — Handles scoring, streak, hearts, powers, learning card on wrong (Rounds 1-3)
- `showLearnCard(entry)` / `dismissLearnCard()` — Learning card overlay on wrong answers
- `renderTeachBack(card, entry)` — Teach It Back round renderer (Round 4, quiz mode only)
- `gachaPull()` — Handles gacha pulls with rarity rolling + pity counter
- `updateShopWizard()` — Renders SVG wizard + set bonus progress in shop
- `updateMiniWizard()` — Renders tiny SVG wizard in HUD
- `getActivePowers()` — Returns array of `{name, tier}` power objects from equipped items + set bonus
- `getPowerScale(powerName)` — Returns scaled value for a power based on equipped tier
- `updateStudyGuide()` — Renders Study Guide with mastery icons, stats, book quotes
- `getMasteryLevel(word)` — Returns mastery icon/class/rank for a word
- `updateMultDisplay()` — Updates chapter multiplier badge on start screen
- `confirmBackToMenu()` — HUD exit button with confirmation

## Game Design

### Round Order (5 total):
1. **Matching Game** (Round 0) — Two-column grid, click word then click matching definition (batches of 6)
2. **Word → Definition** (Round 1) — See the word, pick correct definition from 5 choices
3. **Definition → Word** (Round 2) — See the definition, pick the correct word from 5 choices
4. **Sentence Challenge** (Round 3) — Pick which of 2 sentences uses the word correctly (final boss)
5. **Teach It Back** (Round 4) — Pick the BEST hint to help a friend learn a word (Weekly Quiz bonus round only, triple points)

### Vocabulary Data (Anne of Green Gables):
- **Chapters 7-12**: Week 1 vocabulary (This Week = Ch 13-18 currently)
- **Chapters 13-18**: Week 2 vocabulary
- Total: 72 words across 12 chapters
- Chapter grouping on start screen: "This Week" (Ch 13-18, default ON) and "Last Week" (Ch 7-12, default OFF)
- **Update week grouping in `buildChapters()`** when adding new chapters — move current "This Week" to "Last Week" and add new chapters as "This Week"

### Economy (Rebalanced):
- **Base points**: 5 pts per correct answer (was 10)
- **Streak bonus**: +3 pts at 3+ streak (was +5)
- **Hard round bonus**: +2 pts for rounds 2+ (was +5)
- **Teach It Back**: 15 pts base (triple points)
- **Chapter multiplier**: 0.8x (1 ch) → 1.0x (2 ch) → 1.2x (3-4 ch) → 1.4x (5 ch) → 1.6x (6 ch)
- Multiplier shown as badge next to "Vocab Chapters" title, updates live

### Gacha Shop System:
- **48 items** total: 16 hats, 16 pets, 16 outfits
- **5 rarity tiers**: common, rare, epic, legendary, mythic
- **4 pull tiers**: Basic (40pts), Super (100pts), Mega (250pts), Divine (500pts)
- **Dupe refunds**: common=3, rare=8, epic=20, legendary=40, mythic=80 pts
- **Pity counter**: After 8 consecutive common pulls, next pull guarantees rare+. Resets on any rare+ pull. Persists across sessions.
- **Scaled power system**: Each item has `powerTier` (1-4), power effects scale with tier
- **Set bonuses**: Equipping hat+outfit+pet from same set grants bonus power
- **Mythic items** grant 3 powers at once (mythicWisdom, mythicGuardian, mythicAura)

### Power Types:
| Power | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|-------|--------|--------|--------|--------|
| bonusScore | +1 pt | +2 pts | +3 pts | +5 pts |
| freeHint | 1/round | 1/round | 2/round | 3/round |
| eliminate | remove 1 | remove 2 | remove 2 | remove 3 |
| doublePoints | 1.25x | 1.5x | 1.75x | 2x |
| streakShield | 1 use | 1 use | 2 uses | 3 uses |
| restoreHeart | +1 | +1 | +1 | +2 |
| revive | 2 hearts | 2 hearts | 3 hearts | 3 hearts |
| xpMultiplier | 1.05x | 1.1x | 1.15x | 1.2x |
| wordMaster | +2 pts | +4 pts | +6 pts | +8 pts |
| comboExtender | 1 miss | 1 miss | 2 misses | 2 misses |
| luckyPull | +2% | +5% | +8% | +12% |

### 5 Set Bonuses:
- **Ocean Set** (Pirate Bandana + Sailor Dress + Library Owl) → comboExtender tier 3
- **Space Set** (Space Helmet + Space Suit + Celestial Dragon) → xpMultiplier tier 3
- **K-pop Set** (K-pop Headphones + Idol Jacket + Lucky Cat) → doublePoints tier 2
- **Royal Set** (Royal Crown + Crystal Dress + Sparkle Unicorn) → restoreHeart tier 4
- **Nature Set** (Flower Crown + Fairy Dress + Library Owl) → luckyPull tier 3

### localStorage Persistence:
- **Saves**: wordStats, score (gacha currency), inventory, equipped items, bestStreak, sessionTime, pityCounter, badgeProgress
- **Auto-saves** after every answer, gacha pull, and equip change
- **Auto-loads** on page init
- **Score persists** as gacha currency (NOT reset on new game)
- **Reset button** in Parent Panel ("Reset All Progress")
- **Key**: `vocabquest_save`

### Learning Card (Wrong Answer Teaching):
- On wrong answers in Rounds 1-3, a glassmorphism overlay shows after 2.8s (once feedback fades)
- Shows: word, part of speech, definition, example sentence from SENTENCES
- "Got it!" button to dismiss + 6s auto-dismiss fallback
- Does NOT apply to Round 0 (Matching, tiles stay visible) or Round 4 (Teach It Back, already educational)

### Study Guide:
- Slide-out panel available during gameplay (except boss round and quiz mode)
- Per-word mastery tracker: 🔴 New → 🟡 Learning → 🟢 Good → ⭐ Mastered
- Words sorted weakest-first
- Shows attempt count and accuracy % per word
- Book context quotes (📖) from Anne of Green Gables below each definition
- Mastery levels: none (no data), learning (<75% or <2 att), good (≥75% + 2+ att), mastered (existing flag)

### Weekly Quiz Mode:
- `WEEKLY_QUIZ` config object at top of JS — parent updates 3 values each week
- Toggle on start screen hides chapter/round/multiplier selectors when ON
- **3-part flow**: Part 1 = Matching (bold words), Part 2 = Sentence Challenge (starred words), Part 3 = Teach It Back (all quiz words, bonus round)
- Teach It Back: student picks BEST hint for a friend, alternates between definition hints and sentence types
- Triple points (15 base) for Teach It Back
- `buildQuizRound(part)` — part 0 = matching, part 1 = sentences, part 2 = teach it back

### Hint System (per round):
- **Round 0 (Matching)**: Shows partial definition (first clause before comma/semicolon)
- **Round 1 (Word → Def)**: Shows a correct SENTENCE using the word from SENTENCES object
- **Round 2 (Def → Word)**: Shows first half of the word + total letter count
- **Round 3 (Sentences)**: Shows the full definition to help judge sentence correctness
- **Round 4 (Teach It Back)**: No hints — "You're the teacher now!"

### Other Features:
- **Round selector** on start screen — skip to any round
- **Chapter selector** — pick which chapters to study (grouped by week with toggle headers)
- **Chapter multiplier badge** — inline with chapter title, shows current multiplier
- **Auto-advance** between questions (no "Next" button) — correct: 2s delay, wrong: learning card
- **Hints** (-5 pts, or free with freeHint power) — contextual per round type
- **Hearts** — 3 per round, visual feedback on wrong answers
- **Streak combos** — fire emoji at 3x, MEGA COMBO at 5x
- **Spaced repetition** — missed words get extra copies in the pool
- **Levels** — Trainee, Rookie Idol, Main Vocalist, Center Stage, K-pop Legend
- **Parent Control Panel** — slide-out panel with score, accuracy, mastered/practice words, reset button
- **Mini wizard in HUD** — clickable, opens shop during gameplay
- **Back to menu button** — ✕ in HUD corner with confirmation dialog
- **Redo round button** — on summary screen
- **Practice missed words** — "Comeback Era" button on summary screen

### Theme & Tone:
- **K-pop / Gen Z slang** — Stray Kids & Ateez inspired
- Dark purple/teal/pink/gold color palette with glassmorphism cards
- Rarity-based visual effects: mythic has rainbow color-shifting borders, legendary has gold glow, etc.

## COMPLETED BUILD ✅

### Phases 1-5 (Original Build) ✅
- 48 gacha items, scaled powers, set bonuses, SVG wizard, matching game, weekly quiz mode

### Phase 6: SVG Item Visual Variety ✅
- All 48 items now produce visually distinct wizards
- 12 hat SVG types, 16 pet SVG types (all dedicated, no emoji fallback), outfit color variants

### Phase 7: UX Polish ✅
- Chapter title changed to "Vocab Chapters"
- Week grouping with toggle headers (This Week / Last Week)
- Redo round button on summary
- Study Guide panel with words/definitions during gameplay
- Back to menu button in HUD

### Phase 8: Learning Enhancement ✅
- Learning card overlay on wrong answers (word/def/sentence)
- Per-word mastery tracker in Study Guide (🔴→🟡→🟢→⭐)
- 72 Anne of Green Gables book context quotes
- localStorage persistence (score, inventory, wordStats, equipped)
- 20% chance to show book quote in correct-answer feedback

### Phase 9: Economy Rebalance ✅
- Points cut ~60% (5 base, +3 streak, +2 hard round)
- Pull costs raised (40/100/250/500), dupe refunds lowered
- Chapter multiplier: 0.8x-1.6x based on chapters selected (shown inline)
- Pity counter: guaranteed rare+ after 8 common pulls

### Phase 10: Teach It Back Bonus Round ✅
- Weekly Quiz Part 3: student picks best hint to help a friend
- Alternates definition hints and sentence types (3 options each)
- 72 words × TEACH_HINTS + TEACH_SENTENCES data
- Triple points (15 base)
- No hints allowed — "You're the teacher now!"
- Tracks teachBackCount in badgeProgress

## KNOWN ISSUES / FUTURE IDEAS

### Future Features (Designed but not yet built):
- **Daily Streak Calendar** — 7-day visual strip, 1-day freeze, streak bonus points, persisted
- **Achievement Badges** — 10 badges (Bookworm, Sharpshooter, Comeback Queen, Chapter Champion, Perfect Week, Variety Star, Collector, On Fire, Word Wizard, Teacher's Pet), badge shelf on start screen, popup celebrations
- **Class Word Wall** — Shared class goal, collaborative not competitive (needs backend)
- **Teach It Back in regular mode** — Currently only in Weekly Quiz, could add as optional Round 5
- **Type the Word round** — Recall/spelling round (deferred, may slow kids down)

### SVG Item Visual Variety (completed but could be enhanced):
- Some pets still use simpler SVGs — could add more animation/detail to common pets
- Rarity-scaled flair (more sparkles/glow for higher rarity) partially implemented

## How to Add New Vocabulary

When the user uploads a new vocab photo, update these things:

### 1. Add to `VOCAB` object
```js
19:[
  {word:'newword', pos:'v.', def:'the definition'},
  // ... more words
],
```

### 2. Update `buildChapters()` week grouping
Move current "This Week" chapters to "Last Week" array, add new chapters as "This Week":
```js
const weeks=[
  {label:'This Week',badge:'now',cls:'current',chs:[19,20,21,22,23,24],defaultOn:true},
  {label:'Last Week',badge:'prev',cls:'previous',chs:[13,14,15,16,17,18],defaultOn:false},
  {label:'Week 1',badge:'prev',cls:'previous',chs:[7,8,9,10,11,12],defaultOn:false}
];
```

### 3. Add to `SENTENCES` object
```js
newword:['Correct sentence using ___WORD___ here.','Another correct sentence with ___WORD___.'],
```

### 4. Add to `WRONG_SENTENCES` object
Create 2-3 wrong sentences per word using VARIED misuse types.

### 5. Add to `BOOK_QUOTES` object
```js
newword:'Anne of Green Gables style sentence using the word in context.',
```

### 6. Add to `TEACH_HINTS` object
```js
newword:{best:'Clear helpful clue',vague:'Too vague hint',wrong:'Subtly misleading hint'},
```

### 7. Add to `TEACH_SENTENCES` object
```js
newword:{best:'Clear correct usage sentence',awkward:'Grammatically ok but unclear',wrong:'Subtly wrong usage'},
```

### 8. Update `WEEKLY_QUIZ` config
```js
const WEEKLY_QUIZ={
  label:'Ch 19–24 Quiz',
  matchWords:['word1','word2',...],
  sentenceWords:['word3','word4']
};
```

## Design Decisions & Lessons Learned
- **No "Next" button** — auto-advance keeps momentum high for kids
- **Wrong sentences must be tricky** — silly/absurd wrongs made it too easy to guess
- **Variety in wrong sentence types** — if all wrongs are just "opposite meaning," that's guessable
- **Feedback overlay timing** — 1.8s correct, 2.8s delay then learning card for wrong
- **Learning card on wrong answers** — highest-leverage moment for retention is right after a mistake
- **Font size matters** — increased from initial design for readability
- **Hints should NOT give away the answer** — Word→Def round shows sentence context, not definition
- **Hint strategy per round**: Matching=partial def, Word→Def=sentence context, Def→Word=partial word+length, Sentences=full definition, Teach It Back=none
- **Round selector** — lets parents/kids skip to harder rounds
- **Matching game first** — easiest round first builds confidence, sentence challenge last as "final boss"
- **Scaled powers > unique powers** — with 48 items, same power types at different strengths
- **Set bonuses drive collection** — motivates collecting specific items
- **SVG > emoji for customization** — emoji can't be modified, SVG layers can be swapped
- **Composable SVG primitives** — base shapes with color params cover items without code bloat
- **Score as persistent currency** — don't reset on new game, it's gacha currency
- **Economy balance matters** — original 10pts/20cost was too generous with persistence; 5pts/40cost feels right
- **Chapter multiplier encourages breadth** — studying more chapters = more reward, shown inline so kids see it
- **Pity counter prevents frustration** — 8 commons guarantee a rare+, keeps gacha exciting
- **Teach It Back = deepest learning** — "if you can teach it, you know it" (90% retention)
- **gh-pages needs index.html** — vocab-quest.html must be copied to index.html on deploy

## User Preferences
- Parent is building this for their 11-year-old daughter AND her classmates (class-wide distribution)
- Child likes K-pop (Stray Kids, Ateez specifically)
- Gen Z slang is preferred for all UI text and feedback
- Vocabulary comes from **Anne of Green Gables** study guide, chapter-based
- User uploads new vocab photos each week — just upload in chat and say "add this week's vocab"
- Game hosted on GitHub Pages (https://demerson-code.github.io/vocab-quest/)
- Also runs as a local HTML file (no server needed)
- Character should look youthful — brown braided hair, glasses, freckles (NOT old wizard)
- Gacha items should visually change the wizard character (SVG layer swapping)
- Mid-game story popups were removed as distracting
- Matching game should be the first/easiest round, sentence challenge is the final boss
- User doesn't want typing/spelling rounds (may slow kids down)
- User wants encouragement over competition (no leaderboards ranking students)
- localStorage persistence is per-device automatic (no name/profile system)
- User prefers to build features incrementally and test before deploying
