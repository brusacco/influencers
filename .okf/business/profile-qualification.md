---
type: Business Rule
title: Profile qualification and tracking tiers
description: The enabled, Paraguay, follower, and profile-type rules that decide which profiles are shown, refreshed, and tracked.
tags: [business-rules, metrics]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: instagram-profile-model
    title: Profile model scopes
    resource: ../../app/models/profile.rb
  - id: tiktok-profile-model
    title: TiktokProfile model scopes
    resource: ../../app/models/tiktok_profile.rb
  - id: mentions-task
    title: Add mentions profiles task
    resource: ../../lib/tasks/util/add_mentions_profiles.rake
  - id: related-profiles-task
    title: Add related profiles task
    resource: ../../lib/tasks/util/add_related_profiles.rake
---

# Overview

A profile qualifies for the product when it is enabled and located in Paraguay. Tracking adds a follower floor. The same rule shape applies to Instagram and TikTok profiles.[^instagram-profile-model][^tiktok-profile-model]

# Sets

- `enabled`: the `enabled` flag is true. This controls visibility and ingestion.[^instagram-profile-model]
- `paraguayos`: `country_string` is `Paraguay`.[^instagram-profile-model]
- `micro`: followers of 10,000 or more.[^instagram-profile-model]
- `tracked`: `enabled`, `paraguayos`, and `micro` combined. Daily stats and post refresh use this set.[^instagram-profile-model][^tiktok-profile-model]
- `marcas` and `medios`: `enabled` and `paraguayos` restricted to profile type `marca` or `medio`.[^instagram-profile-model]

# Discovery thresholds

Profiles discovered from mentions must be enabled, Paraguayan, and have 50,000 followers or more.[^mentions-task] Related-profile discovery targets Paraguayan profiles of type `programa` with 50,000 followers or more.[^related-profiles-task]

# Notes

Three follower floors are in use: 10,000 for `tracked`, 40,000 for [collaboration detection](/business/collaboration-detection.md), and 50,000 for discovery. Do not reuse one floor for another purpose. Reuse the scopes instead of rewriting these filters.
