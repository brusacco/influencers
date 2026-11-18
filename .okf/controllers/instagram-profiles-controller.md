---
type: Controller
title: Instagram profiles controller
description: Serves the Instagram profile listings and the profile detail page with charts, relations, and conditional GET.
tags: [public-site, metrics, caching]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T04:00:00Z
sources:
  - id: profiles-controller
    title: ProfilesController
    resource: ../../app/controllers/profiles_controller.rb
  - id: routes
    title: Routes
    resource: ../../config/routes.rb
---

# Routes

`resources :profiles, only: [:index, :show]`, plus the `/posts/liked`, `/posts/video_viewed`, and `/posts/commented` routes that sit beside it.[^routes]

# Actions

- `index` builds four collections from enabled Paraguayan profiles: by followers, by interactions, by video views, and inactive profiles (`total_posts: 0`). Each collection eager-loads the avatar and is capped by `ENGAGEMENT_PROFILES_LIMIT`.[^profiles-controller]
- `show` loads the profile through `before_action :set_profile`, which uses `Profile.enabled.find`. It then pulls the related profiles, mentions, the latest `RECENT_POSTS_LIMIT` posts for the gallery, and a separate 15-day post relation for metrics and charts, plus recent [collaborations](/instagram/collaboration.md). The chart series comes from the [profile stat](/instagram/profile-stat.md) `date` and `followers_count` columns, ordered by date.[^profiles-controller]

# Freshness

`show` calls `fresh_when last_modified: @profile.updated_at.utc, etag: @profile`, so an unchanged profile returns 304. Because [posts touch their profile](/instagram/profile.md), new posts also invalidate this response.[^profiles-controller]

# Notes

- Caching blocks are present but commented out, so only the conditional-GET freshness is active.
- Meta tags come from the [SEO concern](seo-concern.md).
