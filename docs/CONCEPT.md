# Meow-try Dash: The Cursed History — Game Concept

> **Slogan:** *"My funny game for a cat's domain"*
> **Genre formula:** Rhythm-platformer (Geometry Dash-like) × Edu-snack × Cursed-meme aesthetic
> **Engine:** Godot 4 + GDScript
> **Target platforms:** Web (HTML5, primary), Android, iOS, Windows, macOS

This document is the single source of truth for the project. AI agents picking up
any task should read it first.

---

## 1. Identity & tone

**Working title:** Meow-try Dash: The Cursed History

**Audience:**
- Primary: kids 8–13
- Secondary: adult meme enjoyers

Because of the primary audience the "cursed" vibe must be **cartoonishly weird**,
not scary. Hard rules:

- Only bright, daytime / vaporwave-style "creep". No dark corridors.
- Every uncanny element is paired with a meme caption ("HUH?",
  "I am once again asking...") to defuse tension with humor.
- The Biblically Accurate Cat is drawn flat, icon-style — not photoreal.
- No blood, no jump-scares, no harsh stingers.

---

## 2. Content plan — six epochs × three levels (MVP = 18 levels)

| # | Epoch                              | Theme                          | What the kid learns                          | Obstacle / hook                              |
|---|------------------------------------|--------------------------------|----------------------------------------------|----------------------------------------------|
| 1 | Ancient Meow-gypt                  | Bastet, mummies, hieroglyphs   | Why Egyptians deified cats                   | Jumps over sarcophagi, Ra sunbeams           |
| 2 | Neko Shogunate                     | Maneki-neko, samurai           | Japanese "lucky cat" tradition               | Sliding shoji doors, katana metronomes       |
| 3 | Medieval Cat-Castle                | Ship cats, mousers             | Why cats saved harvests and sailors          | Barrels, masts, rocking-ship rhythm          |
| 4 | Renaissance (Cat-a-Lisa)           | Da Vinci, Bosch                | Composition, framing, perspective            | Falling picture frames                       |
| 5 | Cat-Cosmos (USSR → NASA)           | Félicette, the first cat in space | A real historic fact                      | Zero-g = gravity inversion                   |
| 6 | Cyber-Nyan-k                       | Logic gates AND/OR/NOT         | Basic boolean logic                          | Obstacles open only via the correct "gate"   |

Each epoch ends with a **Biblically Accurate Cat boss** that asks one
thematic question. A correct answer unlocks an epoch-themed skin.

---

## 3. Gameplay systems

### MVP (must-have)
1. Tap-to-jump / hold-to-fly (Geometry Dash style).
2. Rhythm-synced obstacles — timings read from a JSON track.
3. **Echo-meow:** a perfectly-timed tap makes the cat meow a note that
   builds the level melody.
4. **Cat-physics zones:** "pipes" change the cat's form
   (Long Cat / Loaf / Blob) via a simple state machine.
   *No real soft-body simulation* — it would cost too much on mobile and
   would be hard for AI to extend reliably.
5. Death = glitch ASCII disintegration + meme card; instant respawn.
6. End-of-epoch boss quiz (1 question, 3 options).

### Nice-to-have (post-MVP)
- In-game level editor that exports the same JSON.
- "Daily cursed cat" rotating meme skin.
- Local co-op "two cats on one screen".

---

## 4. Architecture for AI agents

**Why Godot 4 + GDScript:** short files, text-based scenes (`.tscn`),
diffs read clearly. Copilot / Claude handle GDScript well.

**Agent-friendly principles:**
- One file = one responsibility, ≲ 200 lines.
- All *content* (levels, epochs, questions, skins) lives in **external JSON**,
  never in code. Agents change content without touching logic, reducing
  regressions.
- All "magic numbers" (gravity, speed, timing windows) live in a single
  `GameConfig.tres` resource (script: `GameConfig.gd`).
- Tests cover pure functions only (JSON parser, timing checks, quiz scoring).
  Scenes are not unit-tested — the iteration cost for AI is too high.

### Module tree

```
/scenes/         Player.tscn, Level.tscn, Boss.tscn, MainMenu.tscn
/scripts/
  PlayerController.gd     Normal/Long/Loaf/Blob states + physics
  LevelManager.gd         JSON loader + obstacle spawner per beat
  AudioManager.gd         BPM sync + echo-meow
  QuizManager.gd          Boss-question logic
  GlitchFX.gd             Death FX (ASCII disintegration)
  GameConfig.gd           Tunables (gravity, speeds, timing windows)
/data/
  levels/<epoch>/<n>.json   Obstacle timings
  epochs.json               Epoch metadata
  questions.json            Boss question bank
  skins.json                Unlockable skins
/assets/                Sprites, fonts, audio (per epoch)
/tests/                 GUT tests for parsers and QuizManager
/docs/                  CONCEPT.md, level_schema.md
```

---

## 5. JSON level contract (summary)

The full schema lives in [`level_schema.md`](./level_schema.md). Highlights:

- Timings are stored as **beats**, not seconds — agents respect rhythm more
  easily, and the engine converts beats → seconds using `bpm`.
- `LevelManager.validate()` rejects a level if:
  - any timing is outside `[0, duration_sec * bpm / 60]`;
  - cat-form `physics_zones` overlap;
  - an obstacle `type` is unknown.

Minimal examples sit in `data/levels/meowgypt/01.json` and
`data/levels/renaissance/02.json`.

---

## 6. Cross-platform plan

- **Web (HTML5)** — primary distribution channel for kids (school laptops,
  zero install).
- **Android / iOS** — one-tap control; Godot exports without code changes.
- **Desktop Win / macOS** — development and demos.
- Render target ≥ 1280×720; assets shipped at 2× for retina screens.

---

## 7. MVP roadmap (one PR per item)

1. Godot 4 skeleton + folders + `.gitignore` + Web/Android export presets. ✅ *(this PR)*
2. `PlayerController` (Normal form) + tap-to-jump + collision detection.
3. `LevelManager`: JSON parser + `spike` obstacle spawner by beat.
4. `AudioManager`: track loading + current-beat callback + sync.
5. One hand-authored test level (Ancient Meow-gypt).
6. `GlitchFX` death + instant respawn.
7. Cat-physics forms (Long / Loaf / Blob) + zone triggers.
8. `QuizManager` + Boss scene + one question.
9. Skin system (JSON + unlock on correct answer).
10. Three levels per epoch via AI JSON generation.
11. Menu, progress, save-game.
12. Web export → GitHub Pages for quick demos.

Each item is small enough for a single AI agent to ship as a self-contained PR.

---

## 8. Project status

This repository currently contains the **starter pack**:

- This concept document.
- `docs/level_schema.md` — the JSON level contract.
- A Godot 4 project skeleton with stub scripts (no scenes yet).
- Two example level JSONs and the initial data files.

Next roadmap step: **item #2 — implement `PlayerController` for the Normal form.**
