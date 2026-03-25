# AGENTS

Coding directions for agents working in this repository.

## 1. Objective

Deliver safe, minimal, test-backed changes to Sqily while preserving:

- community-scoped access control
- learning/validation workflow integrity
- side effects (messages, notifications, mailers, jobs)

Read first: `KNOWLEDGE_BASE.md`.

## 2. Mandatory Workflow

For every non-trivial change:

1. Confirm route and params in `config/routes.rb`.
2. Trace guards in controller (`authenticate_user`, `must_be_membership`, role checks).
3. Trace model/form side effects and callbacks.
4. Add or update tests near changed behavior.
5. Run relevant checks (`bin/rails test ...` minimum; `bin/ci` preferred).

## 3. Scope and Safety Rules

- Keep patches focused; avoid broad refactors unless explicitly requested.
- Do not change route shapes or param contracts unless requested.
- Preserve current i18n usage and French copy style where existing.
- Do not silently bypass permission checks.
- Do not remove callbacks/side effects without replacing behavior explicitly.
- Treat `db/schema.rb` as canonical for current data shape.

## 4. Authorization Checklist

Before merging any controller/domain change, verify:

- Who can execute the action? (member/moderator/admin/owner/expert)
- Which guard enforces it? (`before_action` and/or policy method)
- Are object-level checks still applied after refactor?
- Are unauthorized paths covered by tests?

Reference: `app/lib/user/permissions.rb`.

## 5. Side-Effect Checklist

Changes touching these areas must be reviewed for downstream behavior:

- `Skill`, `Subscription`, `Evaluation`, `Evaluation::Exam`, `Homework`
- `Message` subclasses and notifications
- `Workspace` publish/approve/reject flows
- scheduled jobs and mailers

When modifying one of these, validate:

- notification/message creation
- mail dispatch triggers
- completion/progression propagation
- cancellation/uncompletion behavior

## 6. Testing Expectations

Default requirement:

- Add or update at least one focused regression test for changed behavior.

Preferred command set:

```bash
bin/rails test
bundle exec standardrb
bin/brakeman
```

Targeted loop examples:

```bash
bin/rails test test/models/<file>_test.rb
bin/rails test test/controllers/<file>_controller_test.rb
bin/rails test test/jobs/<file>_job_test.rb
```

Coverage baseline is enforced in `test/test_helper.rb` (`SimpleCov` minimum `93.60`).

## 7. Conventions for New Code

- Prefer small methods and explicit names over dense branching.
- Extract query/policy/service logic when controller methods grow.
- Keep SQL fragments localized and tested when needed.
- Reuse existing form objects (`app/lib/*_form.rb`) before adding new orchestration layers.
- Follow existing code style (`standardrb`).

## 8. Frontend/UX Constraints in This Repo

- This is server-rendered Rails + asset pipeline; avoid introducing heavy new frontend frameworks.
- Keep JS additions in existing module structure under `app/assets/javascripts/`.
- Preserve progressive enhancement; pages should remain functional without fragile JS coupling.

## 9. File and Change Hygiene

- Do not commit secrets (`.env`, credentials).
- Do not edit generated artifacts unless required.
- If schema changes are made, ensure migrations and tests are included.
- Keep docs in sync when behavior or architecture changes materially.

## 10. Definition of Done

A task is done when:

- behavior matches requested change
- permissions and side effects remain correct
- tests pass for changed scope
- no obvious regressions in related flow
- docs updated when needed (`KNOWLEDGE_BASE.md`)
