---
type: Model
title: TikTok post model
description: TikTok video record with engagement counts, cover image, and a derived total.
tags: [ingestion, media]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: tiktok-post-model
    title: TiktokPost model
    resource: ../../app/models/tiktok_post.rb
  - id: tiktok-posts-schema
    title: tiktok_posts table schema
    resource: ../../db/schema.rb
---

# Overview

`TiktokPost` belongs to a [TikTok profile](/tiktok/profile.md). It stores one video's description, engagement counts, and cover image.[^tiktok-post-model]

# Schema

Key columns: `tiktok_post_id` (unique), `desc`, `posted_at`, `likes_count`, `comments_count`, `play_count`, `shares_count`, `collects_count`, `total_count`, `video_url`, and `cover_url`.[^tiktok-posts-schema]

# Behavior

- `update_from_api_data` runs `TiktokServices::UpdatePostData` and then `save_cover`.[^tiktok-post-model]
- `caption` returns `desc`, and `video_view_count` returns `play_count`. These aliases keep the Instagram post interface.[^tiktok-post-model]
- `update_total_count` stores likes, comments, shares, and collects in `total_count`.[^tiktok-post-model]
- Includes [JSON data setter](/shared/json-data-setter.md) and [image downloader](/shared/image-downloader.md).
