---
type: Controller
title: API v1 posts controller
description: Token-protected endpoint that returns up to 100 recent posts for one Instagram profile.
tags: [api, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: api-posts-controller
    title: Api::V1::PostsController
    resource: ../../app/controllers/api/v1/posts_controller.rb
---

# Action

`index` (`GET /api/v1/profiles/:username/posts`) requires the [API token](authenticable.md). It returns the profile's [Instagram posts](/instagram/post.md) ordered by `posted_at` descending, limited to 100, serialized by the post serializer. A missing profile returns 404.[^api-posts-controller]

# Gotcha

`total_posts` is `posts.count` on the limited relation. The value therefore never exceeds 100, and it does not report the profile's real post count.[^api-posts-controller]
