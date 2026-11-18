---
type: Controller
title: TikTok profiles controller
description: Serves the TikTok profile listing and detail page, including estimated reach and conditional GET.
tags: [public-site, metrics, caching]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-profiles-controller
    title: TiktokProfilesController
    resource: ../../app/controllers/tiktok_profiles_controller.rb
---

# Actions

- `index` lists `TiktokProfile.enabled.paraguayos` ordered by followers.[^tiktok-profiles-controller]
- `show` loads the profile through `before_action :set_tiktok_profile`, which uses `TiktokProfile.enabled.find`. It loads the last 50 posts and computes metrics from the last week's posts.[^tiktok-profiles-controller]
- Reach comes from the [TikTok profile](/tiktok/profile.md) methods `calculate_estimated_reach` and `calculate_estimated_reach_percentage`. Those rely on the [reach calculator](/shared/reach-calculator.md) concern.[^tiktok-profiles-controller]

# Freshness

`show` calls `fresh_when last_modified: @tiktok_profile.updated_at.utc, etag: @tiktok_profile`, the same pattern as the [Instagram profiles controller](instagram-profiles-controller.md).[^tiktok-profiles-controller]
