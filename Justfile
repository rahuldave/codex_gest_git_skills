setup:
  @echo "No repository-local dependencies to install. Ensure gest, but, gh, just, and ast-grep are available."

lint:
  scripts/check_repo.sh

static: lint

test:
  scripts/run_tag_dependency_agent_dry_run.sh

tag-dependency-dry-run:
  scripts/run_tag_dependency_agent_dry_run.sh

diff-check:
  scripts/check_repo.sh --diff

verify: lint test diff-check
