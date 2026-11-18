---
type: Service
title: Instagram update post data
description: Transforms one Instagram timeline edge into post attributes.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T09:30:00Z
sources:
  - id: instagram-update-post-data
    title: InstagramServices::UpdatePostData
    resource: ../../../app/services/instagram_services/update_post_data.rb
---

# Behavior

- Requires `node` with `__typename`, `shortcode`, `taken_at_timestamp`, and `edge_media_to_comment`.[^instagram-update-post-data]
- Maps `__typename` to `image`, `video`, or `carousel`, and anything else to `unknown`. The post URL is built from the shortcode.[^instagram-update-post-data]
- `posted_at` comes from `taken_at_timestamp`. A bad timestamp raises and is returned as an error.[^instagram-update-post-data]
- Likes come from `edge_liked_by.count`, or from `edge_media_preview_like.count` in cursor mode. Comments come from `edge_media_to_comment.count`. `total_count` is likes plus comments.[^instagram-update-post-data]
- Keeps the full edge in `data` for archiving, as required by AGENTS.md.[^instagram-update-post-data]

The result is written to the [Instagram post](/instagram/post.md) model.

**Deprecation**: No active rake calls this transformer. New ingestion uses
`ScrapeDoGraphqlPostUpserter`, which accepts the current public GraphQL node and
retains only compact metadata.
