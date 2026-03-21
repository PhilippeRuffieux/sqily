# Sqily — Setup and Deployment Guide

This guide covers all the steps needed to duplicate the Sqily project (a Ruby on Rails application for mutual competence validation, built by HEP Vaud). It is split into two independent parts: setting up a local development environment, and deploying a production version to Fly.io.

## Table of Contents

### Part 1 — Local Development

1. [Prerequisites (local)](#1-prerequisites-local)
2. [Clone the repository](#2-clone-the-repository)
3. [Initial configuration](#3-initial-configuration)
4. [Understanding the Docker architecture](#4-understanding-the-docker-architecture)
5. [Start the application](#5-start-the-application)
6. [Create the admin user](#6-create-the-admin-user)
7. [Develop and test changes](#7-develop-and-test-changes)
8. [Useful commands (local)](#8-useful-commands-local)

### Part 2 — Production Deployment

9. [Prerequisites (production)](#9-prerequisites-production)
10. [Create the Fly.io applications](#10-create-the-flyio-applications)
11. [Configure `fly.toml`](#11-configure-flytoml)
12. [Adapt the code for production](#12-adapt-the-code-for-production)
13. [Understanding the production Dockerfile](#13-understanding-the-production-dockerfile)
14. [Configure Rails secrets](#14-configure-rails-secrets)
15. [Configure object storage (Tigris)](#15-configure-object-storage-tigris)
16. [Deploy](#16-deploy)
17. [Verify the deployment](#17-verify-the-deployment)
18. [Useful commands (production)](#18-useful-commands-production)

### Appendices

19. [Scheduled tasks and email](#19-scheduled-tasks-and-email)
20. [Continuous integration (GitHub Actions)](#20-continuous-integration-github-actions)
21. [Known issues and solutions](#21-known-issues-and-solutions)
22. [Summary of modified files](#22-summary-of-modified-files)

---

# Part 1 — Local Development

This part describes how to set up a complete development environment on your machine. It lets you run Sqily locally, modify the code, and test your changes before deploying them to production.

---

## 1. Prerequisites (local)

- **Docker Desktop** — [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
  - On macOS: download the `.dmg`, open it and drag Docker into `/Applications`. Launch Docker Desktop and wait for the menu bar icon to show "Docker Desktop is running".
- **Git** — to clone the repository.

No local installation of Ruby, Rails or PostgreSQL is needed: everything is managed by Docker.

**Project tech stack:**

- Ruby 3.4.7
- Rails 7.2.x
- PostgreSQL 16
- Puma (web server)
- Sprockets (asset pipeline)

---

## 2. Clone the repository

```bash
git clone <REPO_URL> sqily
cd sqily
```

---

## 3. Initial configuration

### 3.1 Generate `config/master.key`

Rails uses a `master.key` file to encrypt credentials. If this file doesn't already exist in the project:

```bash
# Generate a random 32-character hex key
ruby -e "require 'securerandom'; puts SecureRandom.hex(16)" > config/master.key
```

This file must **never** be committed to Git (it is already listed in `.gitignore` and `.dockerignore`). Keep it in a safe place.

### 3.2 Create the `.env` file

Create a `.env` file at the project root. This file holds the environment variables required to start the application:

```bash
cat > .env <<'EOF'
RAILS_MASTER_KEY=<your_master_key>
AWS_BUCKET_URL=https://dev_key:dev_secret@s3-eu-central-1.amazonaws.com/sqily-dev
EOF
```

Both variables are **required**:

- **`RAILS_MASTER_KEY`** — the key generated in step 3.1. Replace `<your_master_key>` with the contents of `config/master.key`.
- **`AWS_BUCKET_URL`** — the S3 bucket URL. The application parses this variable at boot time in the `AwsFileStorage` concern. **Without it, the container will crash** with a `URI::InvalidURIError`. The dummy value above is enough to get started (uploads won't work, but the app will boot). For a working S3 setup, see section 3.3.

The `docker-compose.yml` file automatically loads variables from `.env`. No need to pass them as command prefixes.

> **Note:** `AWS_BUCKET_URL` supports two formats:
> - Standard AWS URL: `https://<access_key>:<secret>@s3-<region>.amazonaws.com/<bucket>`
> - Local S3-compatible endpoint (MinIO): `http://minioadmin:minioadmin@127.0.0.1:9000/sqily-test?region=us-east-1&path_style=true`

### 3.3 Configure S3 storage for development (optional)

For file uploads to work locally, you have two options:

**Option A — Automated script (recommended if you have an AWS account).**
The repository includes a script that creates an S3 bucket and an IAM user with least-privilege permissions:

```bash
chmod +x scripts/setup-aws-s3-dev.sh
./scripts/setup-aws-s3-dev.sh
```

This script creates (or reuses) an S3 bucket in `eu-central-1`, configures public-read access settings compatible with the application, creates an IAM user with a least-privilege inline policy, and writes `AWS_BUCKET_URL` and `AWS_BUCKET_PREFIX=development` to your `.env` file.

Script options:
```bash
./scripts/setup-aws-s3-dev.sh --profile my-admin-profile --project sqily --env-file .env
```

The script requires AWS credentials with IAM + S3 provisioning permissions. If the IAM user already has 2 active access keys, delete one before re-running:
```bash
aws iam list-access-keys --user-name sqily-dev-s3-app
aws iam delete-access-key --user-name sqily-dev-s3-app --access-key-id <key-id>
```

**Option B — Dummy value.**
If you don't need file uploads during development, keep the dummy value in `.env`. The application will start normally but uploads will fail silently.

### 3.4 Verify the `.dockerignore` file

A `.dockerignore` file must exist at the project root with at least:

```
.git
log/*
tmp/*
coverage/*
vendor/bundle
node_modules
.env*
config/master.key
```

This file prevents Docker from including unnecessary or sensitive files in the image.

---

## 4. Understanding the Docker architecture

The project uses a multi-stage `Dockerfile` with 4 stages. Only the first two are used for local development:

- **`base`** — slim Ruby image with system dependencies (ImageMagick, PostgreSQL client, Node.js).
- **`development`** — inherits from `base`, adds build tools (gcc, git, libpq-dev). **This is the stage used by `docker compose`.**
- **`build`** — installs production gems and precompiles assets. Intermediate stage only.
- **Final stage (unnamed)** — lightweight production image. Used by `fly deploy` (see Part 2).

### The `docker-compose.yml` file

```yaml
services:
  web:
    build:
      context: .
      target: development      # Targets the "development" stage of the Dockerfile
    ports: ["3000:3000"]
    environment:
      - DATABASE_URL=postgresql://sqily:sqily@db:5432/sqily_development
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
      - BINDING=0.0.0.0
    volumes:
      - .:/rails                # Mounts source code for hot-reload
      - bundle_cache:/usr/local/bundle
    depends_on:
      db:
        condition: service_healthy
    stdin_open: true
    tty: true

  db:
    image: postgres:16
    environment:
      - POSTGRES_USER=sqily
      - POSTGRES_PASSWORD=sqily
      - POSTGRES_DB=sqily_development
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sqily -d sqily_development"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db_data:
  bundle_cache:
```

Key points:

- `target: development` — tells Docker to only build up to the `development` stage, not the production image.
- `RAILS_MASTER_KEY` — must be provided as an environment variable at launch (see next section).
- The `.:/rails` volume mounts the source code into the container: any file change on your machine is immediately visible in Docker (hot-reload).
- The `bundle_cache` volume persists gems between restarts to avoid reinstalling them every time.

### The `bin/docker-entrypoint` script

In development mode, this script runs automatically on container startup. It installs missing gems and prepares the database:

```bash
#!/bin/bash -e

if [ -z "${LD_PRELOAD+x}" ] && [ -f /usr/local/lib/libjemalloc.so ]; then
  export LD_PRELOAD=/usr/local/lib/libjemalloc.so
fi

if [ "$RAILS_ENV" = "development" ]; then
  bundle check || bundle install
  if [ "$1" == "./bin/rails" ] && [ "$2" == "server" ]; then
    ./bin/rails db:prepare
  fi
fi

exec "${@}"
```

---

## 5. Start the application

If you created the `.env` file (section 3.2), Docker Compose loads the variables automatically. Simply run:

```bash
docker compose up --build
```

The `--build` flag rebuilds the image if needed (equivalent to running `docker compose build` then `docker compose up`). You can also start services in the background with `docker compose up -d`.

Alternatively, if you're not using a `.env` file, pass the master key as a prefix:

```bash
RAILS_MASTER_KEY=<your_master_key> docker compose up --build
```

On first launch, Docker will build the image (a few minutes), install gems, create the database and run migrations. The application will be available at:

> **http://localhost:3000**

> **Note:** A yellow warning `The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8)` will appear on Apple Silicon Macs. This is normal and harmless: Docker emulates x86 architecture via Rosetta. The warning comes from the `--platform=linux/amd64` flag in the Dockerfile, which is required for production on Fly.io.

---

## 6. Create the admin user

The database is empty after initial setup. To create the admin user and seed data, open a bash shell inside the Docker container:

```bash
docker compose run web bash
```

You are now connected as `root` inside the container. Run the seed:

```bash
bundle exec rails db:seed
```

**How the seed works:** The file `db/seeds.rb` contains a single instruction: `Rake.application["db:fixtures:load"].invoke`. Instead of creating users with standard Ruby code, it loads the **test fixtures** (`test/fixtures/users.yml`) directly into the database. This creates 4 users, all with the password `password`:

| User | Email | Admin |
|------|-------|-------|
| Admin | admin@sqily.test | yes |
| Alexis | alexis@basesecrete.test | no |
| Antoine | antoine@basesecrete.test | no |
| Valentin | valentin@basesecrete.test | no |

To log in as administrator, use `admin@sqily.test` / `password`.

To verify the users were created, open a Rails console (still from the container bash):

```bash
bundle exec rails console
```

Then in the console:

```ruby
User.count
# => 4
```

Type `exit` to leave the Rails console, then `exit` again to leave the container.

> **Note:** Inside the Docker container, the bare `rails` command doesn't work (because `./bin` is not in the PATH). Always use `bundle exec rails ...` or `bin/rails ...`.

---

## 7. Develop and test changes

The local environment is designed for the edit → test → deploy cycle. Here is the typical workflow.

### 7.1 Edit code

Edit the project files with your usual editor (VS Code, RubyMine, etc.) directly on your machine. Thanks to the Docker volume (`.:/rails`), changes are immediately visible inside the container. Rails reloads code on every request in development mode: no need to restart the server.

### 7.2 Run tests

Open a shell in the container and run the test suite:

```bash
docker compose run web bash
bundle exec rails test
```

Or for a specific test file:

```bash
bundle exec rails test test/controllers/skills_controller_test.rb
```

### 7.3 Check code quality

Two verification tools are available:

```bash
docker compose run web bash

# Ruby linting (StandardRB — style conventions)
bundle exec standardrb

# Security audit (Brakeman — detects Rails vulnerabilities)
bin/brakeman
```

Both commands are run automatically by the GitHub Actions CI. It is recommended to run them before each commit.

### 7.4 Open a Rails console

To inspect data or test Ruby code:

```bash
docker compose run web bash
bundle exec rails console
```

### 7.5 Run migrations

After adding or modifying a migration:

```bash
docker compose run web bash
bundle exec rails db:migrate
```

### 7.6 Reset the database

To start from scratch (drops all data, recreates the schema and re-runs the seed):

```bash
docker compose run web bash
bundle exec rails db:drop db:create db:schema:load db:seed
```

### 7.7 Clear caches and logs

If assets (CSS, JS) don't reflect your changes:

```bash
docker compose run web bash
bundle exec rails log:clear tmp:clear
```

Then restart the server.

### 7.8 Restart after Gemfile or Dockerfile changes

If you add a gem or modify the Dockerfile, stop the containers (`Ctrl+C`) then relaunch with rebuild:

```bash
docker compose up --build
```

### 7.9 Deploy changes to production

Once your changes are tested locally, commit them and deploy:

```bash
git add .
git commit -m "Description of changes"
fly deploy
```

The `fly deploy` command rebuilds the production image (last stage of the Dockerfile), runs migrations via the `release_command`, and restarts the machines. See Part 2 for details.

---

## 8. Useful commands (local)

| Action | Command |
|--------|---------|
| Start the application | `docker compose up --build` |
| Start in background | `docker compose up -d` |
| Stop services | `docker compose down` |
| Open bash in container | `docker compose run web bash` |
| Create demo users | `bundle exec rails db:seed` * |
| Rails console | `bundle exec rails console` * |
| Run tests | `bundle exec rails test` * |
| Ruby linting | `bundle exec standardrb` * |
| Security audit | `bin/brakeman` * |
| Run migrations | `bundle exec rails db:migrate` * |
| Full database reset | `bundle exec rails db:drop db:create db:schema:load db:seed` * |
| Clear caches and logs | `bundle exec rails log:clear tmp:clear` * |

\* These commands must be run from a bash shell inside the container (`docker compose run web bash`).

---

# Part 2 — Production Deployment

This part describes how to deploy Sqily to Fly.io to make it accessible on the Internet. It assumes you have completed Part 1 and the project works locally.

---

## 9. Prerequisites (production)

In addition to the Part 1 prerequisites, you will need:

- **A Fly.io account** — create one at [fly.io](https://fly.io). A free plan is sufficient for a demo.
- **flyctl** (Fly.io CLI) — install it via Homebrew:
  ```bash
  brew install flyctl
  ```
  Then authenticate:
  ```bash
  fly auth login
  ```

---

## 10. Create the Fly.io applications

Two applications are needed on Fly.io: one for Rails, one for PostgreSQL.

1. Create **the Rails application** (2 machines will be created automatically):
   ```bash
   fly apps create sqily
   ```
   If the name `sqily` is already taken, choose another name and replace it in all subsequent commands.

2. Create **the PostgreSQL database** (1 machine, 1 GB storage):
   ```bash
   fly postgres create --name sqily-db --region cdg \
     --vm-size shared-cpu-1x --initial-cluster-size 1 --volume-size 1
   ```

3. Attach the database to the application:
   ```bash
   fly postgres attach sqily-db --app sqily
   ```
   This command automatically creates a `DATABASE_URL` secret in the `sqily` application.

4. Check the status of your applications from the Fly.io dashboard:
   - Rails application: `https://fly.io/apps/sqily`
   - PostgreSQL database: `https://fly.io/apps/sqily-db`

---

## 11. Configure `fly.toml`

Create (or verify) the `fly.toml` file at the project root:

```toml
app = "sqily"
primary_region = "cdg"        # Paris — choose the nearest region

[build]

[env]
  RAILS_ENV = "production"
  RAILS_LOG_TO_STDOUT = "true"
  RAILS_SERVE_STATIC_FILES = "true"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0

[deploy]
  release_command = "bin/rails db:prepare"

[[vm]]
  memory = "512mb"
  cpus = 1
```

Key points:

- **`release_command`** — runs `db:prepare` (creates the database if needed, runs migrations) before each deployment.
- **`auto_stop_machines`** — shuts down the VM after inactivity (saves budget in demo mode).
- **`min_machines_running = 0`** — allows full shutdown. The first request will be slow (cold start of a few seconds).

---

## 12. Adapt the code for production

Two changes are needed in the Rails code for the application to work on Fly.io.

### 12.1 Enable `assume_ssl` in `config/environments/production.rb`

Fly.io terminates SSL at its proxy and forwards requests as HTTP to the application. Without `assume_ssl`, Rails enters an infinite redirect loop (301 → 301 → 301...).

Uncomment or add this line (around line 49):

```ruby
config.assume_ssl = true
```

It must coexist with `config.force_ssl = true` (which is still needed for secure cookies and HSTS).

### 12.2 Handle the absence of `git` in `config/application.rb`

The production Docker image does not include `git`. If your code calls `git rev-parse HEAD`, it will crash with `Errno::ENOENT`. Modify the `latest_commit_id` method:

```ruby
def self.latest_commit_id
  @latest_commit_id ||= ENV["FLY_IMAGE_REF"] || (`git rev-parse HEAD`.strip rescue "unknown")
end
```

This uses the `FLY_IMAGE_REF` variable provided automatically by Fly, with a graceful fallback.

### 12.3 Add the `production` section to `config/database.yml`

Make sure your `config/database.yml` file contains a production section that uses the `DATABASE_URL` variable:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV["DATABASE_URL"] %>
```

---

## 13. Understanding the production Dockerfile

The multi-stage Dockerfile is the cornerstone of deployment. The development stage was described in Part 1. Here are the critical points for production (the last stage in the file):

```dockerfile
# syntax=docker/dockerfile:1
# check=skip=FromPlatformFlagConstDisallowed

ARG RUBY_VERSION=3.4.7

# Force linux/amd64 because Fly.io VMs are x86_64
FROM --platform=linux/amd64 docker.io/library/ruby:$RUBY_VERSION-slim AS base
WORKDIR /rails

# System dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl imagemagick libjemalloc2 libmagickwand-dev \
      libpq5 libyaml-dev nodejs postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH="/usr/local/bundle"

# ... development and build stages (see Part 1, section 4) ...

# Final production stage (must be the LAST stage)
FROM base

ENV RAILS_ENV="production" \
    RAILS_LOG_TO_STDOUT="true" \
    RAILS_SERVE_STATIC_FILES="true"

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log tmp && \
    chmod -R a+r /rails          # Important: makes all files readable

USER 1000:1000
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
```

Critical points:

- **`--platform=linux/amd64`** — required when building from an Apple Silicon Mac (M1/M2/M3/M4). Without it, Docker produces an ARM64 image that doesn't work on Fly.io's x86_64 VMs (error `exit_code=-1`).
- **`check=skip=FromPlatformFlagConstDisallowed`** — disables the Docker linter warning about the `--platform` flag.
- **`chmod -R a+r /rails`** — the `rails` user (UID 1000) must be able to read all files, including `config/database.yml`. Without this: `Permission denied`.
- **No ENTRYPOINT** in production — `bin/docker-entrypoint` is designed for development (`bundle install`, `db:prepare`). In production, `db:prepare` is handled by the `release_command` in `fly.toml`.
- **No `LD_PRELOAD` for jemalloc** in production — the jemalloc symlink can cause crashes on cross-architecture builds. The library is installed but not activated.
- **The final stage has no name** (`FROM base` not `FROM base AS production`) — this is important because Fly.io always builds the last stage.

---

## 14. Configure Rails secrets

```bash
fly secrets set SECRET_KEY_BASE=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)") --app sqily
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key) --app sqily
```

You can also manage secrets from the dashboard: `https://fly.io/apps/sqily/secrets`

---

## 15. Configure object storage (Tigris)

Sqily uses AWS S3 to store uploaded files (assignments, documents, etc.). On Fly.io, the simplest option is **Tigris**, an S3-compatible service integrated with Fly.

### 15.1 Create a Tigris bucket

Create a bucket directly from the Fly CLI:

```bash
fly storage create --name sqily-files --app sqily
```

Answer `yes` to accept the Tigris terms of service.

### 15.2 Find your access keys

Go to the Tigris console to find your keys:

- Tigris dashboard on Fly: `https://fly.io/dashboard/<YOUR-ORG>/tigris`
- Tigris console (access keys): `https://console.tigris.dev/to_<YOUR_ORG_ID>/accesskeys`

You will find three pieces of information:

- **Endpoint URL**: `https://t3.storage.dev`
- **Access Key ID**: a key in the format `tid_XXXX_XXXXXXXXXXXXXXXXXXXXXXXX`
- **Secret Access Key**: a key in the format `tsec_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

The Secret Access Key is shown **only once** when the key pair is created. If you've lost it, you will need to generate a new pair.

### 15.3 Configure storage secrets

The `AwsFileStorage` concern in Sqily supports two configuration modes:

**Option A — Single `AWS_BUCKET_URL` variable (legacy mode).**
All information is encoded in a single URL:

```
AWS_BUCKET_URL=https://<ACCESS_KEY_ID>:<SECRET_ACCESS_KEY>@t3.storage.dev/<BUCKET_NAME>
```

Concretely, the format is:
```
https://tid_XXXX_XXXX:tsec_XXXX@t3.storage.dev/sqily
```

Special characters in the Secret Access Key must be URL-encoded:
- `+` → `%2B`
- `/` → `%2F`
- `=` → `%3D`

To configure this secret in Fly:
```bash
fly secrets set "AWS_BUCKET_URL=https://tid_XXXX:tsec_XXXX@t3.storage.dev/sqily" --app sqily
```

**Option B — Separate variables (recommended Tigris mode).**
If `fly storage create` was used, these variables are already configured automatically:

```bash
fly secrets set BUCKET_NAME="sqily-files" --app sqily
fly secrets set AWS_REGION="auto" --app sqily
fly secrets set AWS_ENDPOINT_URL_S3="https://t3.storage.dev" --app sqily
fly secrets set AWS_ACCESS_KEY_ID="tid_XXXX_XXXX" --app sqily
fly secrets set AWS_SECRET_ACCESS_KEY="tsec_XXXX" --app sqily
```

This option avoids URL-encoding issues and is more readable.

### 15.4 How the code chooses the mode

The file `app/models/concerns/aws_file_storage.rb` automatically detects which mode to use:

- If `AWS_BUCKET_URL` is defined → legacy mode (parses the URL to extract key, secret, endpoint and bucket).
- Otherwise → Tigris / standard AWS mode (uses the separate variables `BUCKET_NAME`, `AWS_ACCESS_KEY_ID`, etc.).

If both are configured, `AWS_BUCKET_URL` takes priority.

---

## 16. Deploy

```bash
fly deploy
```

This command builds the Docker image (Fly's remote builder or locally), pushes it to the Fly registry, runs the `release_command` (`db:prepare`), then starts the machines.

The first deployment takes 3 to 5 minutes. You will see logs scrolling. At the end:

```
Machines are starting...
Visit your app at https://sqily.fly.dev/
```

---

## 17. Verify the deployment

### 17.1 Test HTTP access

```bash
curl -o /dev/null -s -w "%{http_code}" https://sqily.fly.dev/
```

You should get `200`.

### 17.2 Check the logs

```bash
fly logs --app sqily
```

### 17.3 Open a remote Rails console

```bash
fly ssh console --app sqily --command "bin/rails runner 'puts User.count'"
```

For an interactive console:

```bash
fly ssh console --app sqily --command "bin/rails console"
```

### 17.4 Verify configured secrets

```bash
fly secrets list --app sqily
```

You should see at least:
- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `SECRET_KEY_BASE`
- `BUCKET_NAME`
- `AWS_REGION`
- `AWS_ENDPOINT_URL_S3`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

---

## 18. Useful commands (production)

| Action | Command |
|--------|---------|
| Deploy a new version | `fly deploy` |
| View logs in real time | `fly logs` |
| Open Rails console | `fly ssh console --command "bin/rails console"` |
| Run migrations | `fly ssh console --command "bin/rails db:migrate"` |
| View machine status | `fly status` |
| Restart the application | `fly apps restart sqily` |
| View secrets | `fly secrets list` |
| Add a secret | `fly secrets set NAME=value` |
| Open the app in browser | `fly open` |
| Diagnose problems | `fly doctor` |
| Connect to PostgreSQL | `fly postgres connect --app sqily-db` |

---

# Appendices

## 19. Scheduled tasks and email

### Scheduled tasks (cron)

Sqily uses scheduled tasks defined in `config/schedule.rb`:

- **Every hour**: `sqily:hourly`
- **Every day at 08:00**: `sqily:daily`

The tasks themselves are defined in `lib/tasks/sqily.rake`. In local development, you can run them manually:

```bash
docker compose run web bash
bundle exec rake sqily:hourly
bundle exec rake sqily:daily
```

To regenerate the local crontab:
```bash
bundle exec rake sqily:update_crontab
```

### Email configuration

In production, email delivery is configured via the `SMTP_URL` variable in `config/environments/production.rb`. The format is a standard URI: `smtp://user:password@host:port`.

In local development, no email service is preconfigured. Emails are logged to the console. If you need to view emails, you can configure [letter_opener](https://github.com/ryanb/letter_opener) or [mailcatcher](https://mailcatcher.me/).

---

## 20. Continuous integration (GitHub Actions)

The project uses GitHub Actions for CI. The workflow (`.github/workflows/ci.yml`) runs on every push:

1. `bundle exec rails test` — the test suite
2. `bundle exec standardrb` — Ruby linting
3. `bin/brakeman` — security audit

### S3 storage in CI

Instead of using a real AWS bucket, CI starts a **MinIO** service (local S3-compatible server) and points `AWS_BUCKET_URL` to that endpoint. This exercises the real S3 storage code path without requiring cloud credentials.

No GitHub secret is needed for CI: neither `AWS_BUCKET_URL`, nor `AWS_BUCKET_PREFIX`, nor `RAILS_MASTER_KEY`.

### Difference between local dev and CI

- In **local development**, you can use a real AWS bucket via `.env` and the `scripts/setup-aws-s3-dev.sh` script (see section 3.3), or a dummy value if uploads are not needed.
- In **CI**, MinIO is used by default to avoid any cloud dependency.

---

## 21. Known issues and solutions

### `exit_code=-1` when Fly machines start

**Cause:** Docker image built for ARM64 (Apple Silicon) while Fly VMs are x86_64.

**Fix:** Add `--platform=linux/amd64` to the base `FROM` in the Dockerfile. Also add `# check=skip=FromPlatformFlagConstDisallowed` at the top of the file to suppress the linter warning.

### Infinite 301 redirect loop

**Cause:** `config.force_ssl = true` in `production.rb` without `config.assume_ssl = true`. Fly.io terminates SSL at the proxy; the app receives HTTP and redirects to HTTPS in a loop.

**Fix:** Add `config.assume_ssl = true` in `config/environments/production.rb`.

### `Errno::ENOENT - git` in production

**Cause:** The code calls `git rev-parse HEAD` but `git` is not installed in the production image (unnecessary and bulky).

**Fix:** Use a fallback in `config/application.rb`:
```ruby
@latest_commit_id ||= ENV["FLY_IMAGE_REF"] || (`git rev-parse HEAD`.strip rescue "unknown")
```

### `Permission denied` on `config/database.yml`

**Cause:** The `rails` user (UID 1000) doesn't have read permissions on files copied into the image.

**Fix:** Add `chmod -R a+r /rails` in the Dockerfile, after the `COPY`.

### Fly secrets not visible in the machine

**Cause:** Machines were updated manually with `fly machine update`, which can strip secret injection.

**Fix:** Destroy the manually modified machines and do a clean `fly deploy`:
```bash
fly machines list
fly machines destroy <MACHINE_ID> --force
fly deploy
```

### Errors with `AWS_BUCKET_URL` containing special characters

**Cause:** Characters like `@`, `+`, `/` in AWS keys don't pass well through a URL.

**Fix:** Use separate variables (Tigris mode) instead of a monolithic URL. If you must use `AWS_BUCKET_URL`, URL-encode special characters (`+` → `%2B`, `/` → `%2F`, etc.).

### `jemalloc` causes crashes in cross-compilation

**Cause:** The jemalloc symlink created on ARM doesn't work in a cross-architecture emulated context.

**Fix:** Install `libjemalloc2` but don't configure `LD_PRELOAD` in the production stage. `bin/docker-entrypoint` enables it only in development.

### `rails: command not found` in the Docker container

**Cause:** The container's `PATH` doesn't include `./bin`. The bare `rails` command can't find the executable.

**Fix:** Always use `bundle exec rails ...` or `bin/rails ...` from the container bash.

### The `web` container crashes immediately on startup

**Cause:** The `AWS_BUCKET_URL` variable is not set or invalid. The application parses this URL at boot in `app/models/concerns/aws_file_storage.rb` and raises a `URI::InvalidURIError`.

**Fix:** Verify that the `.env` file contains `AWS_BUCKET_URL` with a valid URL (even a dummy one), then recreate the containers:
```bash
docker compose down
docker compose up --build
```

### S3 tests fail with `Aws::S3::Errors::InvalidAccessKeyId`

**Cause:** Tests try to access an S3 bucket but the credentials in `AWS_BUCKET_URL` are dummy or invalid.

**Fix:** Configure a real S3 endpoint via the `scripts/setup-aws-s3-dev.sh` script (section 3.3), or use a local MinIO endpoint. Then recreate the containers.

### Assets (CSS/JS) don't reflect changes

**Cause:** Stale Sprockets cache or temporary files.

**Fix:**
```bash
docker compose run web bash
bundle exec rails log:clear tmp:clear
```
Then restart the server.

### Inconsistent role/permission behavior

**Cause:** The current user's admin/moderator/member flags are not as expected, or the community context (permalink in URL) is incorrect.

**Fix:** Check the user flags in the Rails console:
```ruby
u = User.find_by(email: "admin@sqily.test")
u.admin?  # => true
```
For deterministic behavior, use the seed-created users (section 6).

---

## 22. Summary of modified files

| File | Modification |
|------|-------------|
| `Dockerfile` | Complete rewrite as multi-stage (development / build / production) with `--platform=linux/amd64` |
| `docker-compose.yml` | Added `target: development` in the `build` section |
| `fly.toml` | Created Fly.io configuration file |
| `.dockerignore` | Created to exclude `.git`, `log`, `tmp`, `master.key`, etc. |
| `.env` | Created with `RAILS_MASTER_KEY` and `AWS_BUCKET_URL` |
| `config/database.yml` | Added `production` section with `DATABASE_URL` |
| `config/environments/production.rb` | Enabled `config.assume_ssl = true` |
| `config/application.rb` | Fallback for `latest_commit_id` when `git` is absent |
| `bin/docker-entrypoint` | Made `bundle install` and `db:prepare` conditional on development mode |
| `app/models/concerns/aws_file_storage.rb` | Dual-mode support: legacy URL or separate Tigris variables |
| `config/master.key` | Generated Rails encryption key |
