# Copilot Instructions for AI Agents

## Project Overview

This is a Ruby on Rails application for managing and analyzing influencer profiles, primarily focused on Instagram. The codebase is organized using standard Rails conventions, but includes custom service objects and admin modules for extended functionality.

## Architecture & Major Components

- **app/models/**: Core business logic, including `InstagramProfile` (formerly `Profile`), `InstagramPost`, and related models.
- **app/controllers/**: RESTful controllers for categories, profiles, posts, and tags. Admin controllers are in `app/admin/`.
- **app/services/**: Service objects for external integrations (e.g., Facebook data import).
- **app/views/**: ERB templates for user-facing and admin interfaces.
- **Active Storage**: Used for file uploads (avatars, images). If models are renamed, update `active_storage_attachments.record_type` accordingly.

## Developer Workflows

- **Start server**: `bin/rails server` or use `Procfile.dev` for multi-process dev setup.
- **Run tests**: `bin/rails test` (unit, integration, system tests in `test/`).
- **Database migrations**: `bin/rails db:migrate`. For model renames, also update related Active Storage records.
- **Docker**: `docker-compose.yml` for containerized development.

## Project-Specific Patterns

- **Model Renames**: When renaming models (e.g., `Profile` → `InstagramProfile`), update:
  - All references in code, views, and controllers
  - Active Storage attachments (`record_type` in DB)
  - Table names via migration (`rename_table :profiles, :instagram_profiles`)
- **Service Objects**: Located in `app/services/`, used for external API calls and data imports. Follow the pattern in `facebook_services/get_profile_data.rb`.
- **Admin Namespace**: Custom admin logic in `app/admin/`, separate from standard controllers.
- **Partial Rendering**: Pass explicit `as:` option when rendering collections to ensure correct local variable naming in partials.

## Integration Points

- **External APIs**: Facebook and Instagram data import via service objects.
- **Active Storage**: For file uploads; ensure correct model linkage after schema changes.
- **Docker**: Use for local development and testing.

## Examples

- To render a collection of profiles in a view:
  ```erb
  <%= render partial: "profiles/profile", collection: @instagram_profiles, as: :profile %>
  ```
- To update Active Storage after a model rename:
  ```ruby
  # Migration example
  execute "UPDATE active_storage_attachments SET record_type = 'InstagramProfile' WHERE record_type = 'Profile'"
  ```

## Key Files & Directories

- `app/models/instagram_profile.rb`
- `app/controllers/profiles_controller.rb`
- `app/services/facebook_services/get_profile_data.rb`
- `db/migrate/` (for schema changes)
- `Procfile.dev`, `docker-compose.yml` (for dev setup)

---

If any conventions or workflows are unclear, please ask for clarification or examples from the codebase.
