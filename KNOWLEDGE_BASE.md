# Sqily Knowledge Base

This document is an implementation-grounded snapshot of the current codebase.  
It is intended as context for coding agents and contributors.

## 1. Project Purpose

Sqily is a Rails web platform for competency-based learning and peer validation (VMC).  
Core loops include:

- Skill discovery and progression through a community skill tree.
- Learner subscription and completion tracking.
- Validation workflows (evaluations, exams, notes, homework).
- Collaboration (messages, polls, events, workspaces).
- Community governance (memberships, moderation, invitations, teams).

Primary reference: `README.md`.

## 2. Runtime and Stack

- Framework: Ruby on Rails `~> 7.2.0`
- Ruby: `3.4.7` (`.ruby-version`)
- DB: PostgreSQL
- App server: Puma
- Jobs/scheduling:
  - ActiveJob classes (`app/jobs/**`)
  - cron via `whenever` (`config/schedule.rb`, `lib/tasks/sqily.rake`)
- Frontend:
  - ERB views + Rails asset pipeline (Sprockets)
  - Legacy JS modules in `app/assets/javascripts/**`
- Storage:
  - custom S3/public storage concerns (`AwsFileStorage`, `AwsAvatarStorage`)
  - local storage concern fallback (`PublicFileStorage`)
- Email: ActionMailer + SMTP (`SMTP_URL`)

## 3. Repository Map (high signal)

- Domain and web app code: `app/`
  - `app/models`: rich domain logic and callbacks
  - `app/controllers`: route handling + authorization gates
  - `app/lib`: form objects and policies-like helpers (`SkillForm`, `User::Permissions`, etc.)
- Routing: `config/routes.rb`
- Schema truth: `db/schema.rb` (version `2026_01_15_152937`)
- Tests: `test/**` (Minitest, fixture-heavy)
- Quality gate script: `bin/ci`

## 4. Core Domain Model

Main entities:

- Identity/governance:
  - `User`, `Community`, `Membership`, `Team`
  - `Invitation`, `InvitationRequest`, `CommunityRequest`
- Learning structure:
  - `Skill` (tree via `parent_id`), `Prerequisite`, `Task`, `DoneTask`, `Subscription`
- Assessment:
  - `Evaluation`, `Evaluation::Draft`, `Evaluation::Exam`, `Evaluation::Note`, `Homework`
- Collaboration:
  - `Message` (+ typed subclasses), `Vote`, `HashTag`
  - `Poll`, `PollChoice`, `PollAnswer`
  - `Event`, `Participation`, `WaitingParticipation`
- Portfolio:
  - `Workspace`, `Workspace::Version`, `Workspace::Partnership`, `Workspace::Lock`
- Signals:
  - `Notification` types, `Badge` types, `PageView`

## 5. Request and Access Model

Global patterns:

- Most community routes are permalink-scoped (`/:permalink/...`).
- `ApplicationController` provides:
  - `current_community`
  - `current_membership`
  - `authenticate_user`
  - `must_be_membership`
  - `must_be_moderator`
- Admin namespace (`/admin/*`) is separate and admin-guarded.

Authorization is a mix of:

- Controller `before_action` guards
- `User::Permissions` checks (object-level actions)
- Model predicates (`pinnable_by?`, `viewable_by?`, etc.)

## 6. Critical Business Flows (implemented)

- Skill architecture and progression:
  - creation/update through `SkillForm`
  - hierarchical constraints, prerequisite graph, task tracking
  - subscription propagation to parents
- Assessment orchestration:
  - evaluation definition
  - exam start with examiner selection
  - threaded notes with accept/reject semantics
  - accepted note completes subscription
- Homework:
  - upload evidence, approve/reject cycle, retries on rejection
- Messaging:
  - direct/community/skill/workspace contexts
  - polling endpoint (`messages#index` JSON/HTML partial behavior)
- Events:
  - capacity, waiting list promotion, registration deadline checks
- Workspaces:
  - versioning + approvals + publish/unpublish and related messages

## 7. High-Impact Models and Behaviors

- `Skill`:
  - `startable_by?` prerequisite + parent recursion
  - `subscribe`/`unsubscribe` recursive parent handling
  - around-save hook reorganizes subscriptions after structure changes
- `Subscription`:
  - completion/uncompletion and parent cascade
  - exam state cleanup on uncomplete
- `Evaluation`:
  - `start(subscription, content)` creates/resumes exam
  - `pick_examiner_for` uses load + team preference + prior examiner avoidance
- `Evaluation::Exam`:
  - ongoing/completed/canceled state via flags + accepted notes
  - `add_note` can trigger subscription completion
- `Message`:
  - recipient validation ensures one target scope exists
  - visibility and pinning rules enforced in model methods
- `Workspace`:
  - publish/unpublish/approve/reject with message side effects
- `Event`:
  - register/unregister + waiting-list promotion

## 8. Side Effects and Coupling Hotspots

Behavior is often callback- and side-effect-driven:

- Model saves can create messages/notifications/emails.
- Subscription/evaluation/homework changes can trigger cascades.
- Scheduling tasks trigger periodic summary/reminder jobs.

This means small data changes may have broad downstream effects.

## 9. Testing and Quality Baseline

- Test framework: Minitest (`test/**`)
- Fixtures: global fixtures (`fixtures :all`)
- Coverage gate: SimpleCov minimum `93.60%`
- CI command chain (`bin/ci`):
  - `rails test`
  - `bundle exec standardrb`
  - `bin/brakeman`

## 10. Known Technical Characteristics / Risks

- Large controllers and callback-heavy models increase change risk.
- Many flows rely on implicit side effects.
- No integration/system test layer currently (`test/integration` empty).
- Polling messaging architecture (not WebSocket).
- Permission coverage is mixed; some endpoints are documented as missing explicit guards.

## 11. Agent Orientation: Where to Start for Any Change

1. Confirm route in `config/routes.rb`.
2. Inspect controller action + `before_action` guards.
3. Trace model/service side effects (callbacks, mailers, jobs, message/notification triggers).
4. Update/add tests in `test/models`, `test/controllers`, and `test/jobs` as needed.
5. Run `bin/ci` 

## 12. Source of Truth Priority

When docs and code differ, trust in this order:

1. `db/schema.rb` and executable code in `app/**`
2. tests in `test/**`
3. `README.md`
