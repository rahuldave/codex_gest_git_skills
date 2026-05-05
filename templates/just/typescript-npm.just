export npm_config_cache := ".local/npm-cache"

setup:
  npm install

lint path="src package.json tsconfig.json":
  npm exec -- biome check {{path}}

typecheck:
  npm exec -- tsc --noEmit

build:
  npm exec -- tsc

test target="":
  npm exec -- tsc
  node --test dist/*.test.js {{target}}

diff-check:
  git diff --check

verify: lint typecheck build test diff-check
