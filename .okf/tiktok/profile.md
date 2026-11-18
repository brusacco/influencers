---
type: Model
title: TikTok profile model
description: TikTok account record with follower metrics, avatar, post sync, and reach estimation.
tags: [metrics, reach, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: tiktok-profile-model
    title: TiktokProfile model
    resource: ../../app/models/tiktok_profile.rb
  - id: tiktok-profiles-schema
    title: tiktok_profiles table schema
    resource: ../../db/schema.rb
---

# Overview

`TiktokProfile` is the TikTok equivalent of the [Instagram profile](/instagram/profile.md). It shares the same `profile_type` enum and the `enabled`, `country_string`, and follower scopes.[^tiktok-profile-model]

# Schema

Key columns: `username` and `unique_id` (both unique, nullable), `nickname`, `followers`, `following`, `hearts`, `video_count`, `enabled`, `country_string`, `profile_type`, and the `avatar_*` URLs.[^tiktok-profiles-schema]

# Concerns

Includes [JSON data setter](/shared/json-data-setter.md), [image downloader](/shared/image-downloader.md), and [reach calculator](/shared/reach-calculator.md).[^tiktok-profile-model]

# Lifecycle

- `after_create` calls `TiktokServices::GetProfileData`, then `UpdateProfileData`, then `save_avatar`. Skipped when `username` is blank.[^tiktok-profile-model]
- `update_posts` fetches posts through `TiktokServices::GetPostsData`, upserts each one by `tiktok_post_id`, and returns a summary of counts and errors.[^tiktok-profile-model]

# Scope note

This model does not call `acts_as_taggable_on`, so TikTok profiles have no tags.[^tiktok-profile-model]
