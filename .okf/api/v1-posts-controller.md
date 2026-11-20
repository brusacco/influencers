---
type: Controller
title: API v1 posts controller
description: Token-protected endpoints for profile posts and recent Instagram posts filtered by profile type.
tags: [api, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-20T12:00:00Z
sources:
  - id: api-posts-controller
    title: Api::V1::PostsController
    resource: ../../app/controllers/api/v1/posts_controller.rb
---

# Action

`collection` (`GET /api/v1/posts`) requires the [API token](authenticable.md). It returns Instagram posts from the last 24 hours, ordered by `posted_at` descending. The optional `profile_type` query parameter filters joined profiles; supported values are `hombre`, `mujer`, `marca`, `medio`, `estatal`, `memes`, and `programa`. Unknown values return 422. This collection is not limited to enabled or Paraguayan profiles. `post_image_url` uses the attached Active Storage image, then `data.ferrum.display_uri`, then the public-card placeholder URL.

`search` (`GET /api/v1/posts/search?q=keyword&limit=24`) requires the API token and a nonblank `q` parameter. It searches Instagram `caption` values across posts from the last 24 hours, newest first, with an optional `profile_type` filter. It defaults to 24 results and caps `limit` at 100. Unknown profile types return 422.

`index` (`GET /api/v1/profiles/:username/posts`) requires the [API token](authenticable.md). It returns the profile's [Instagram posts](/instagram/post.md) ordered by `posted_at` descending, limited to 100, serialized by the post serializer. A missing profile returns 404.[^api-posts-controller]

# Gotcha

`total_posts` is `posts.count` on the limited relation. The value therefore never exceeds 100, and it does not report the profile's real post count.[^api-posts-controller]
