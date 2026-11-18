---
type: Controller
title: API v1 profiles controller
description: Public profile search and token-protected profile lookup under /api/v1/profiles.
tags: [api, public-site, performance]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: api-profiles-controller
    title: Api::V1::ProfilesController
    resource: ../../app/controllers/api/v1/profiles_controller.rb
---

# Actions

- `search` (`GET /api/v1/profiles/search?q=&page=`) is public and skips the [token check](authenticable.md). A blank `q` returns `{ profiles: [], has_more: false }`. Otherwise it searches `Profile.enabled.paraguayos` where `username` or `full_name` matches `%q%`, ordered by `followers` descending. Pages hold 10 results. One extra row is fetched to set `has_more`. Each result has `id`, `username`, `full_name`, `followers`, `avatar_url`, and `profile_url`.[^api-profiles-controller]
- `show` (`GET /api/v1/profiles/:username`) requires the token. It returns the [Instagram profile serializer](/instagram/profile.md) output as JSON, or 404 with `Profile not found`.[^api-profiles-controller]

# Performance gotcha

`search` matches with `LIKE '%query%'` on two columns. A leading wildcard cannot use a B-tree index, so every call scans the matching profile rows before paging. Any index change needs a schema review under AGENTS.md.[^api-profiles-controller]
