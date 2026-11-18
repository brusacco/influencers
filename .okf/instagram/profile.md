---
type: Model
title: Instagram profile model
description: Instagram account record with normalized metrics, categorization, collaborations, and avatar.
tags: [metrics, ingestion, tagging]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T07:45:00Z
sources:
  - id: profile-model
    title: Profile model
    resource: ../../app/models/profile.rb
  - id: profiles-schema
    title: profiles table schema
    resource: ../../db/schema.rb
---

# Overview

`Profile` maps an Instagram account, keyed by a unique `username`, to its normalized public metrics, categorization, and avatar.[^profile-model] The raw provider payload is kept in the serialized `data` column, while the normalized fields drive pages, the API, and filters.[^profile-model]

# Schema

Key columns: `username`, `followers`, `following`, `enabled`, `country_string`, `profile_type` (enum: hombre, mujer, marca, medio, estatal, memes, programa), `uid`, `engagement_rate`, and the `total_*` counters.[^profiles-schema]

# Associations

- `has_many` [posts](/instagram/post.md) and [daily stats](/instagram/profile-stat.md), both destroyed with the profile.
- Collaborations run through [collaboration](/instagram/collaboration.md) records as collaborator and as collaborated. Both sides are filtered to enabled Paraguayan profiles.
- Categorization uses `acts_as_taggable_on :tags` against the [tag](/shared/tag.md) model.
- The `avatar` attachment holds the profile picture.

# Scopes

`enabled`, `paraguayos`, `micro` (followers of 10,000 or more), and `macro` (50,000 or more). Combined scopes are `tracked`, `marcas`, and `medios`. Reuse these instead of duplicating filters.

# Lifecycle

- `after_create` calls the legacy remote fetch through `InstagramServices::GetProfileData` and `UpdateProfileData`, then saves the avatar. The scheduled `instagram:update_profiles` task instead uses the Scrape.do GraphQL profile services. It defaults to one worker and can use 2 through 10 with `INSTAGRAM_SCRAPE_DO_CONCURRENCY`. Bulk creation therefore still triggers external requests.
- `save_avatar` tries the freshly updated GraphQL avatar URL before the legacy HD URL and attaches only successful image responses. It rejects error documents or non-image responses, preventing expired upstream URL messages from being stored and served as profile pictures.
- `update_profile_stats` sums the last week of posts into the `total_*` counters and recalculates `engagement_rate`.
- Posts `touch` their profile, so changing posts also changes profile freshness.

# Reach estimation

`estimated_reach` blends a follower-based estimate (weight 0.6) with an interaction-based estimate (weight 0.4), capped at 50% of followers.[^profile-model] Its constants are local to this model. It does not include the [reach calculator](/shared/reach-calculator.md) concern, so the two reach formulas differ.

# Legacy helpers

`save_avatar_new` writes avatars into `public/images/profiles`. Prefer `save_avatar`, which uses Active Storage, because media should not move into `public/`.
