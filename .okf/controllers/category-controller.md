---
type: Controller
title: Category controller
description: Serves the category page, which lists enabled Paraguayan profiles of one profile type in three orders.
tags: [public-site, seo]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: category-controller
    title: CategoryController
    resource: ../../app/controllers/category_controller.rb
---

# Action

`show` filters `Profile.enabled.paraguayos` by `profile_type` and returns three lists ordered by followers, total interactions, and total video views. Each list is capped by its own constant.[^category-controller]

The page sets its meta tags through the [SEO concern](seo-concern.md). The page-cache line is commented out, so the response is not cached.[^category-controller]
