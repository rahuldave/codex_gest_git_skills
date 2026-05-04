export UV_CACHE_DIR := ".local/uv-cache"

setup:
  uv sync

lint path=".":
  uv run ruff check {{path}}

typecheck:
  uv run ty check

test target="tests":
  uv run python -m pytest {{target}}
