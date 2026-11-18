---
type: Admin Resource
title: Instagram profiles admin
description: The Active Admin resource for Instagram profiles, with its filters, scopes, batch action, and member refresh.
tags: [admin, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: profiles-admin
    title: Profiles admin resource
    resource: ../../app/admin/profiles.rb
  - id: profile-model
    title: Profile model
    resource: ../../app/models/profile.rb
---

# Listing

The index filters by username, country (`Paraguay` or `Otros`), profile type, category, enabled state, private and business flags, followers, biography, and data.[^profiles-admin]

Scopes group records by country (`all`, `paraguayos`, `otros`, `no_country`) and by status (`enabled`, `disabled`), plus `no_profile_type`.[^profiles-admin][^profile-model]

# Actions

- A batch action, `update_profile`, calls `Profile#update_profile` for each selected record and redirects with the current filters preserved.[^profiles-admin]
- A member action, `update_profile`, does the same for one profile and runs inline in the request rather than through a job.[^profiles-admin]
- A scoped collection update form declares fields for country, profile type, enabled, and tags.[^profiles-admin]

# Form

The form exposes `enabled` as "Enabled (Show/Track profile)". Country defaults to `Paraguay`, so new profiles created in the admin are Paraguayan unless changed.[^profiles-admin]

Creating a profile here triggers the remote fetch on create described in the [Instagram profile model](/instagram/profile.md).[^profile-model]

# Related

Disable and re-enable rules are in the [automatic disabling policy](/business/auto-disable-policy.md).
