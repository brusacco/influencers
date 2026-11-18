---
type: Controller
title: Tags controller
description: Serves the tag index and tag detail pages, which list the Paraguayan profiles carrying a tag.
tags: [public-site, tagging, performance]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tags-controller
    title: TagsController
    resource: ../../app/controllers/tags_controller.rb
---

# Actions

- `index` joins [tags](/shared/tag.md) through taggings to Paraguayan, enabled profiles, groups by tag, and orders by `taggings_count`.[^tags-controller]
- `show` lists enabled Paraguayan profiles tagged with the tag name in three orders: followers, interactions, and video views.[^tags-controller]

# Notes

- The show action collects profile ids with `pluck(:id)` and then runs a separate `WHERE profile_id IN (...)` query for the week's posts. This is an extra round trip that a subquery would avoid.[^tags-controller]
- Meta tags come from the [SEO concern](seo-concern.md).
