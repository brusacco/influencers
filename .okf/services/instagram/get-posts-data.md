---
type: Service
title: Instagram get posts data
description: Fetches regular posts and reels for an Instagram profile from the same web profile payload.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: instagram-get-posts-data
    title: InstagramServices::GetPostsData
    resource: ../../../app/services/instagram_services/get_posts_data.rb
---

# Behavior

- `GetPostsData.call(profile)` requires a profile with a non-blank username. It fetches the payload with the profile's username through [Base](base.md).[^instagram-get-posts-data]
- Returns the concatenation of `edge_owner_to_timeline_media.edges` and `edge_felix_video_timeline.edges`. Missing or non-array edges become an empty list.[^instagram-get-posts-data]
- Each edge is transformed later by [Update post data](update-post-data.md).[^instagram-get-posts-data]
- Errors use the same handling as [Get profile data](get-profile-data.md).[^instagram-get-posts-data]
