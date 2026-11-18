# AGENTS.md

Project-specific guidance for working in this repository.

## Stack

- Ruby 3.3.0 and Rails 7.0.x (see `Gemfile` and `Gemfile.lock`).
- MySQL is the application database through `mysql2`; development and test use the local MySQL service described in `config/database.yml`.
- The frontend uses import maps, Turbo, Stimulus, Tailwind CSS, SassC, and Sprockets.
- Active Admin and Devise provide the administration interface; Active Storage stores avatars and post media.
- Key supporting gems include HTTParty, Oj, ActsAsTaggableOn, Chartkick, Groupdate, Whenever, Ruby OpenAI, SitemapGenerator, MetaTags, and `actionpack-page_caching`.
- Puma is the web server. `Procfile.dev`, `bin/dev`, and `docker-compose.yml` are the local-run entry points.

## Repository Layout

- `app/models/` contains Instagram and TikTok domain models, concerns, and associations.
- `app/controllers/` contains the public HTML controllers, API v1 controllers, and error handling. `app/admin/` contains Active Admin resources.
- `app/services/instagram_services/` and `app/services/tiktok_services/` isolate provider fetching, transformation, retries, and error classification. Keep external API behavior there rather than in controllers or models.
- `app/serializers/instagram/serializers/` defines the public API representation.
- `app/views/`, `app/helpers/`, `app/assets/`, and `app/javascript/` contain the public UI. New browser behavior belongs in a Stimulus controller rather than inline JavaScript.
- `lib/tasks/instagram/`, `lib/tasks/tiktok/`, `lib/tasks/util/`, `lib/tasks/ai/`, and `lib/tasks/data/` contain operational and maintenance tasks.
- `config/schedule.rb` is the source of truth for Whenever/cron schedules.
- `db/migrate/` is authoritative for schema changes; do not edit `db/schema.rb` directly.
- `docs/` contains API, integration, deployment, and calculation documentation. Update the relevant document when behavior or an externally visible contract changes.
- `storage/` and generated files under `public/` are runtime artifacts; do not add or modify them unless the task explicitly requires it.

## Domain Overview

- `Profile` and `InstagramPost` represent Instagram accounts and their posts. `InstagramProfileStat` stores daily historical metrics and `InstagramCollaboration` records profile-to-profile collaborations.
- `TiktokProfile` and `TiktokPost` are the TikTok equivalents. Both profile types share enabled, Paraguay, follower, and profile-type conventions.
- The product primarily presents enabled Paraguayan accounts. Preserve `enabled`, `country_string: 'Paraguay'`, profile-type, and follower thresholds when extending listings or rankings unless the requested behavior differs.
- Raw upstream payloads are retained in serialized `data` columns; normalized fields drive public pages, API output, filters, and aggregates.
- `Tag` and `taggings` power profile categorization. `AdminUser` is the only application authentication model.
- The public site exposes profile, TikTok profile, tag, post, category, legal, and API v1 routes. Keep API serializers and documentation in sync with public API changes.

## Working Rules

- Prefer small, focused changes that match the existing Rails 7 style. Do not broadly modernize or reformat unrelated code.
- Inspect the relevant model, controller, service, task, serializer, view, and tests before changing behavior.
- MANDATORY: for any code exploration, change, or refactor, use CodeGraph first whenever `.codegraph/` exists at the repository root. Do not fall back to broad grep, find, or source reading until it has been consulted.
- Keep controllers focused on request orchestration. Put provider communication in service classes and reusable domain logic in models or concerns, following the existing patterns.
- Reuse existing scopes such as `enabled`, `paraguayos`, `tracked`, `marcas`, and `medios` instead of duplicating filters.
- Queries run against potentially large profile and post datasets. Check `db/schema.rb` indexes before adding filters or order clauses, and avoid non-sargable predicates, correlated subqueries, and unbounded request-path scans.
- Preserve the raw `data` payload during ingestion unless the task intentionally changes the retained source data. Make field extraction defensive because providers can omit or change keys.
- Treat external API calls as fallible: preserve validation, timeout handling, retry/backoff, error classification, and logging conventions in the relevant service namespace.
- Do not expose API keys, provider tokens, database credentials, or `.env` values in code, logs, tests, or documentation.
- Treat `POST /deploy` and scheduled ingestion tasks as operationally sensitive. Do not invoke deployment, mass-update, cleanup, or network-heavy tasks unless the request explicitly requires it.
- Use ASCII by default when creating or editing files unless a user-facing Spanish string needs accents.

## Data, Storage, And Performance

- Create schema changes through a timestamped migration and confirm the resulting indexes support the query shape. Regenerate `db/schema.rb` through Rails, never by hand.
- Instagram media uses `Profile#avatar` and `InstagramPost#image`; TikTok media uses `TiktokProfile#avatar` and `TiktokPost#cover`. Preserve attachment names and avoid moving media into `public/` without an explicit migration plan.
- `belongs_to ... touch: true` on posts deliberately invalidates profile freshness. Account for this when changing ingestion or caching behavior.
- Historical Instagram charts read `InstagramProfileStat` ordered by `date`; retain the unique profile/date invariant and use bulk-friendly access for reporting changes.
- `Profile` callbacks fetch remote data after creation. Avoid bulk record creation paths that accidentally trigger large external fetches; use a deliberate task or service when bulk ingestion is intended.

## Frontend And Caching

- Use Tailwind conventions already present in the affected templates and stylesheets. Check both desktop and mobile rendering when changing public views.
- New JavaScript should be a Stimulus controller registered in `app/javascript/controllers/`; use Turbo-compatible lifecycle hooks.
- Preserve `fresh_when` behavior on public profile pages when changing what determines page freshness.
- Do not casually enable page or fragment caching. If modifying a cached response, identify cache invalidation and deployment implications first.

## Scheduled Jobs

- Every 3 hours: `instagram:update_news_posts`.
- Every 6 hours: `instagram:update_posts`.
- Every 12 hours: `instagram:update_profiles_stats`.
- Every 24 hours: `instagram:update_profiles`, `util:collaborations`, and `util:add_mentions_profiles`.
- Daily at 00:00: `instagram:create_daily_stats` and `tiktok:update_posts`.
- Change `config/schedule.rb` together with the task implementation and explain any altered load, provider quota, or data-freshness impact.

## Testing And Verification

- Add or update tests under `test/` for changed behavior. Follow nearby Minitest fixtures and test style.
- Use the narrowest relevant verification first:
  - `bin/rails test test/models/profile_test.rb`
  - `bin/rails test test/models/tiktok_profile_test.rb`
  - `bin/rails test test/controllers/profiles_controller_test.rb`
  - `bin/rails test`
  - `bin/rails routes`
  - `bin/rails db:migrate`
- Test configuration targets `influencers_test` on local MySQL. Never point test commands at development or production data.
- For service changes, test error paths as well as successful payload transformation. Do not make real provider calls in ordinary tests.
- For stylesheet changes, use the existing asset build/check workflow rather than introducing a new Sass implementation.

## Documentation

- Update the relevant `docs/` page when changing public API responses, authentication behavior, external integrations, operational procedures, metric definitions, or deployment requirements.
- Treat the API documentation as a contract: keep routes, authentication expectations, serializers, and examples aligned.
- Some documentation links reference files not currently present. Do not create placeholder documents solely to satisfy a link; add documentation only when it serves the change.

## OKF

If a `.okf/` directory exists at the repository root:

- Use OKF first to understand business rules, architecture, terminology, and implementation patterns.
- Read `.okf/index.md` and `.okf/log.md` before broad code scanning.
- Consult source code after locating the relevant concepts.
- If OKF does not contain the required information, rely on the existing implementation rather than assumptions.
- When exploration while consuming teaches something durable that OKF lacks, record it in the bundle (write-back rule under Working Rules).
- For bundle questions or updates, use the OKF skill at `.agents/skills/okf/SKILL.md`.
- After any behavioral code change, update the affected `.okf/` concept(s) in the same change: bump `timestamp`, fix cross-links, update the directory `index.md` listing if a concept was added, renamed, or removed, and append a dated entry to `.okf/log.md`.
- Before finishing, run `okf validate .okf` and `okf lint .okf --stale-after 90d` and resolve what they report. New assets get a new concept; retired assets get a `**Deprecation**` note rather than silent deletion.

If no `.okf/` directory exists, continue normally.

## CodeGraph

If a `.codegraph/` directory exists at the repository root:

- Use CodeGraph first for symbol lookup, file mapping, and execution-flow tracing before grep or repo-wide scans.
- Use it to identify the controller/model/service/task/serializer relationships relevant to a change, then inspect only the required source files.
- If CodeGraph does not resolve the question (missing index, unsupported query, or stale/missing symbols), fall back to scoped grep limited to relevant directories such as `app/models`, `app/controllers`, `app/services`, `app/serializers`, or `lib/tasks`.

If no `.codegraph/` directory exists, continue normally.
