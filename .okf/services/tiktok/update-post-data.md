---
type: Service
title: TikTok update post data
description: Transforms one TikTok itemList entry into post attributes.
tags: [ingestion, media, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-update-post-data
    title: TiktokServices::UpdatePostData
    resource: ../../../app/services/tiktok_services/update_post_data.rb
---

# Behavior

- Requires `id` and `createTime`. Other fields default to empty hashes.[^tiktok-update-post-data]
- Maps the stats to likes, comments, shares, plays, and collects. `total_count` is the sum of likes, comments, shares, and collects.[^tiktok-update-post-data]
- Video and music URLs come from `video` and `music`. `posted_at` comes from `createTime`.[^tiktok-update-post-data]
- Stores the full entry in `data`. The result feeds the [TikTok post](/tiktok/post.md) model.[^tiktok-update-post-data]
