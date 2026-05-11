# geometry_cats — Meow-try Dash: The Cursed History

> *"My funny game for a cat's domain"*

A Geometry Dash-like rhythm platformer with **cursed-meme cats** and a sprinkle
of **history & culture**. Built in **Godot 4 + GDScript** and designed from
the ground up to be developed through AI agents (GitHub Copilot, Claude, etc.).

## What's in this repository (starter pack)

This is the project bootstrap. No gameplay runs yet — it's the foundation
future PRs build on.

```
docs/
  CONCEPT.md         Full game concept — single source of truth.
  level_schema.md    JSON contract for levels (agents read this to generate content).
scripts/
  GameConfig.gd      Central tunables (gravity, speeds, timing windows).
  PlayerController.gd  Cat states & death signal (stub).
  LevelManager.gd    JSON loader + full validator (works today).
  AudioManager.gd    BPM-synced playback + beat signal (stub).
  QuizManager.gd     Boss-question scoring (pure functions).
  GlitchFX.gd        Death FX entry point (stub).
data/
  epochs.json        The six historical epochs.
  questions.json     Boss question bank.
  skins.json         Unlockable skins.
  levels/            Per-epoch JSON levels (2 examples included).
tests/               GUT test stubs for pure functions.
project.godot        Godot 4 project descriptor.
icon.svg             Placeholder cursed-cat icon.
```

## Read first

1. **[docs/CONCEPT.md](docs/CONCEPT.md)** — what this game is and why.
2. **[docs/level_schema.md](docs/level_schema.md)** — how to generate levels.

## Roadmap

The MVP is broken into 12 small PRs, each landable by a single AI agent.
See section 7 of `CONCEPT.md`. **Next up: roadmap item #2 — implement
`PlayerController` for the Normal form.**

## License

See [LICENSE](LICENSE).
