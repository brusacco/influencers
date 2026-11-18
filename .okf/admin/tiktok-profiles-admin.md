---
type: Admin Resource
title: TikTok profiles admin
description: The Active Admin resource for TikTok profiles, with its filters, size and status scopes, and the update profile and update posts actions.
tags: [admin, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: tiktok-profiles-admin
    title: TikTok profiles admin resource
    resource: ../../app/admin/tiktok_profiles.rb
---

# Listing

The index filters by username, unique id, nickname, country, profile type, enabled state, private flag, verified flag, followers, hearts, video count, and timestamps.[^tiktok-profiles-admin]

Scopes group records by country, by status (`enabled`, `disabled`), and by size (`micro`, `macro`).[^tiktok-profiles-admin]

# Actions

- Batch action `update_profile` refreshes each selected profile and keeps the current filters.[^tiktok-profiles-admin]
- Member action `update_profile` refreshes one profile.[^tiktok-profiles-admin]
- Member action `update_posts` calls `update_posts` on the profile and reports created and updated counts, plus any errors, in a flash message.[^tiktok-profiles-admin]

Both member actions run inline in the request rather than through a job, so the response waits on the provider calls.[^tiktok-profiles-admin]

# Related

Profile qualification is in [profile qualification](/business/profile-qualification.md). The model is in the [TikTok profile model](/tiktok/profile.md).
