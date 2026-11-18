---
type: Controller
title: Posts controller
description: Serves the daily top-post lists for likes, video views, comments, and total engagement.
tags: [public-site, metrics, performance]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: posts-controller
    title: PostsController
    resource: ../../app/controllers/posts_controller.rb
---

# Actions

`index`, `liked`, `video_viewed`, and `commented` each query [Instagram posts](/instagram/post.md) from the last day (`a_day_ago`). Each sorts by a different count and applies a hardcoded limit: 20 for the total-engagement list and 48 for the category lists.[^posts-controller]

# Notes

- There is no pagination parameter, so the limit is the only bound on each list.[^posts-controller]
- No caching is configured.
