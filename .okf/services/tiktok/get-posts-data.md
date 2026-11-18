---
type: Service
title: TikTok get posts data
description: Fetches feed posts for a TikTok user from the public posts endpoint by secUid.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-get-posts-data
    title: TiktokServices::GetPostsData
    resource: ../../../app/services/tiktok_services/get_posts_data.rb
---

# Behavior

- Resolves the secUid from an explicit `sec_uid`, from the profile, or by calling [Get profile data](get-profile-data.md) for a username. Otherwise it raises `ArgumentError`.[^tiktok-get-posts-data]
- The secUid must start with `MS4wLjABAAA`. Any other value raises `ArgumentError`.[^tiktok-get-posts-data]
- Requests at most 30 posts per call and passes `cursor` through when present. The call runs through [Base](base.md) with retry.[^tiktok-get-posts-data]
- Returns the `itemList` array. A missing `itemList` raises `APIError`. Each entry is mapped by [Update post data](update-post-data.md).[^tiktok-get-posts-data]
