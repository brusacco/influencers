---
type: Model
title: Instagram post model
description: Instagram post record with engagement counts, media image, and caption text analysis helpers.
tags: [ingestion, text-analysis]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T04:15:00Z
sources:
  - id: post-model
    title: InstagramPost model
    resource: ../../app/models/instagram_post.rb
  - id: profiles-schema
    title: instagram_posts table schema
    resource: ../../db/schema.rb
---

# Overview

`InstagramPost` belongs to a [profile](/instagram/profile.md) and stores one post's media type, caption, URL, and engagement counts.[^post-model] The raw payload is kept in the serialized `data` column.[^post-model]

# Schema

Key columns: `shortcode`, `caption`, `likes_count`, `comments_count`, `video_view_count`, `media`, `product_type`, `url`, `posted_at`, `total_count`, and `profile_id`. Indexes cover `profile_id` with `posted_at`, which serves the recent-post queries.[^profiles-schema]

# Behavior

- `a_day_ago`, `a_week_ago`, `last_15_days`, and `a_month_ago` filter on `posted_at`.
- `update_total_count` stores `likes_count + comments_count` in `total_count`.[^post-model]
- `save_image` attaches the media image through Active Storage and falls back to a placeholder when the download fails.
- Public post cards remain visible when the attachment is absent: they use the retained GraphQL `display_uri` when available, otherwise a visual placeholder.
- Public post cards display likes and views when available, but not comment counts because the current GraphQL grid response does not provide reliable comment data.
- `collabs` is an empty stub.

# Caption analysis

`word_occurrences` and `bigram_occurrences` count words and two-word phrases across captions. Each keeps only items seen more than once, skips stop words, URLs, and numeric tokens, and returns the top results.[^post-model]

# Related

Collaborations recorded on a post are described in [collaboration](/instagram/collaboration.md).
