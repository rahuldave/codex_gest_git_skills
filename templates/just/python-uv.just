setup:
  uv sync

lint path=".":
  uv run ruff check {{path}}

typecheck:
  uv run ty check

test target="tests":
  uv run pytest {{target}}
