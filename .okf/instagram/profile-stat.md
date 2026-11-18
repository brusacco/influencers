---
type: Model
title: Instagram profile stat model
description: One row per profile per day holding a historical snapshot of follower and engagement metrics.
tags: [metrics, history]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: profile-stat-model
    title: InstagramProfileStat model
    resource: ../../app/models/instagram_profile_stat.rb
  - id: profile-stats-schema
    title: instagram_profile_stats table schema
    resource: ../../db/schema.rb
---

# Overview

`InstagramProfileStat` stores the daily history of a [profile's](/instagram/profile.md) metrics, which historical charts read ordered by `date`.[^profile-stat-model]

# Schema

Columns: `profile_id`, `date`, `followers_count`, `total_likes`, `total_comments`, `total_video_views`, `total_interactions_count`, `total_posts`, `total_videos`, and `engagement_rate`.[^profile-stats-schema]

# Invariants

- A unique index on `profile_id` and `date` allows at most one row per profile per day.[^profile-stats-schema]
- The model has no validations or scopes. The database index is the only enforcement of uniqueness.[^profile-stat-model]
