# Level JSON schema

Levels are pure data. `LevelManager.gd` loads, validates, and plays them.
This contract is the agreement between **AI agents that generate levels**
and **the engine that runs them**.

> All timings are expressed in **beats**, not seconds.
> The engine converts beats → seconds at runtime using `bpm`:
> `t_seconds = beat * 60.0 / bpm`.
>
> Total beat budget for a level is `duration_sec * bpm / 60.0`.

---

## Top-level object

| Field            | Type     | Required | Notes                                                                 |
|------------------|----------|----------|-----------------------------------------------------------------------|
| `id`             | string   | yes      | Unique slug, snake_case. Example: `"meowgypt_01"`.                    |
| `epoch`          | string   | yes      | One of the epoch ids defined in `data/epochs.json`.                   |
| `title`          | string   | yes      | Human-readable level title (can be playful / non-ASCII).              |
| `bpm`            | int      | yes      | Range `60..240`.                                                      |
| `duration_sec`   | int      | yes      | Range `15..300`.                                                      |
| `music`          | string   | yes      | Godot resource path: `res://assets/music/<file>.ogg`.                 |
| `background`     | string   | yes      | Background asset id (resolved by `LevelManager`).                     |
| `palette`        | string[] | yes      | 3 hex colors, used for procedural decor and HUD tinting.              |
| `physics_zones`  | array    | no       | See "Physics zones" below. Default `[]`.                              |
| `obstacles`      | array    | yes      | See "Obstacles" below. May be empty for tutorial levels.              |
| `collectibles`   | array    | no       | See "Collectibles" below. Default `[]`.                               |
| `boss`           | object   | no       | Present only on the last level of an epoch.                           |

### Physics zones

A physics zone forces the cat into a specific form between `start_beat`
(inclusive) and `end_beat` (exclusive).

```json
{ "start_beat": 16, "end_beat": 24, "form": "long" }
```

| Field         | Type    | Notes                                                                      |
|---------------|---------|----------------------------------------------------------------------------|
| `start_beat`  | number  | `>= 0`, `< duration_sec * bpm / 60`.                                       |
| `end_beat`    | number  | `> start_beat`, `<= duration_sec * bpm / 60`.                              |
| `form`        | string  | One of `"normal"`, `"long"`, `"loaf"`, `"blob"`.                           |

**Validation:** zones must not overlap. Between zones the cat is `"normal"`.

### Obstacles

```json
{ "beat": 6, "type": "frame", "lane": "air" }
```

| Field   | Type    | Notes                                                                      |
|---------|---------|----------------------------------------------------------------------------|
| `beat`  | number  | `>= 0`, `<= duration_sec * bpm / 60`.                                      |
| `type`  | string  | See "Obstacle types" below.                                                |
| `lane`  | string  | One of `"ground"`, `"air"`. Determines spawn Y.                            |

#### Obstacle types (extensible)

The engine consults a registry. Initial set:

| Type        | Visual                  | Behavior                                       |
|-------------|-------------------------|------------------------------------------------|
| `spike`     | Triangular spikes       | Instant kill on contact.                       |
| `frame`     | Picture frame           | Renaissance epoch — kill on contact.           |
| `sarcophagus` | Sarcophagus block     | Meow-gypt — solid; cat must jump over.         |
| `ra_beam`   | Vertical sunbeam        | Meow-gypt — kill on contact.                   |
| `shoji`     | Sliding paper door      | Neko — opens on beat, otherwise blocks.        |
| `barrel`    | Wooden barrel           | Cat-castle — solid, jumpable.                  |
| `gate_and`  | Logic gate AND          | Cyber — opens when 2 switches are active.      |
| `gate_or`   | Logic gate OR           | Cyber — opens when ≥1 switch is active.        |
| `gate_not`  | Logic gate NOT          | Cyber — inverted state.                        |

Agents adding a new obstacle must register it in `LevelManager._OBSTACLE_TYPES`.

### Collectibles

```json
{ "beat": 12, "type": "fish_coin" }
```

| Field   | Type    | Notes                                                                      |
|---------|---------|----------------------------------------------------------------------------|
| `beat`  | number  | In-range, same rule as obstacles.                                          |
| `type`  | string  | `"fish_coin"`, `"yarn_ball"`, `"daily_cursed"`.                            |

### Boss

```json
{
  "name": "Biblically Accurate Da Vinci Cat",
  "question_id": "ren_q1"
}
```

| Field         | Type    | Notes                                                                  |
|---------------|---------|------------------------------------------------------------------------|
| `name`        | string  | Displayed boss name.                                                   |
| `question_id` | string  | Must exist in `data/questions.json`.                                   |

---

## Full minimal example

```json
{
  "id": "renaissance_02",
  "epoch": "renaissance",
  "title": "Cat-a-Lisa",
  "bpm": 120,
  "duration_sec": 60,
  "music": "res://assets/music/renaissance_02.ogg",
  "background": "davinci_workshop",
  "palette": ["#f3e5c1", "#8b5a2b", "#2c1810"],
  "physics_zones": [
    { "start_beat": 16, "end_beat": 24, "form": "long" },
    { "start_beat": 40, "end_beat": 44, "form": "loaf" }
  ],
  "obstacles": [
    { "beat": 4, "type": "spike", "lane": "ground" },
    { "beat": 6, "type": "frame", "lane": "air"    },
    { "beat": 8, "type": "spike", "lane": "ground" }
  ],
  "collectibles": [
    { "beat": 12, "type": "fish_coin" }
  ],
  "boss": {
    "name": "Biblically Accurate Da Vinci Cat",
    "question_id": "ren_q1"
  }
}
```

---

## Validation rules (enforced by `LevelManager.validate()`)

1. All required top-level fields are present and of the correct type.
2. `bpm` and `duration_sec` are within their declared ranges.
3. `palette` has exactly 3 entries, each a 7-char `#RRGGBB` hex string.
4. Every `beat` (in obstacles, collectibles, zones) is in
   `[0, duration_sec * bpm / 60]`.
5. Every `physics_zones[i].end_beat > start_beat`.
6. `physics_zones` do not overlap.
7. Every obstacle `type` is registered.
8. Every collectible `type` is registered.
9. `epoch` matches an id in `data/epochs.json`.
10. If `boss` is present, `boss.question_id` resolves in `data/questions.json`.

Validation failures are reported as a list of strings, not as a single boolean,
so agents can fix multiple issues per generation cycle.

---

## Prompting agents to generate a level

A working prompt template:

> "Generate a level JSON for the **Renaissance** epoch, 60 seconds, 120 BPM,
> 3 physics zones (mix of long/loaf), no boss. Follow
> `docs/level_schema.md` exactly. Output JSON only."

The engine's validator is authoritative — if an agent disagrees with the
schema, the schema wins.
