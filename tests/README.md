# Tests

Pure-function unit tests live here. They run under
[GUT](https://github.com/bitwes/Gut) — to be wired up when CI is added in a
later roadmap PR.

## What we test

- `LevelManager.validate()` — accepts good levels, rejects malformed ones.
- `LevelManager.load_level()` — parses example JSONs without error.
- `QuizManager.is_correct()` — returns the expected boolean.

## What we do **not** test

- Scene trees (`*.tscn`) — too expensive for AI iteration.
- Rendering / shaders.
- Audio playback timing.

## Adding a test

Create `test_<thing>.gd` in this directory, extending `GutTest`. Keep tests
deterministic and dependency-free.
