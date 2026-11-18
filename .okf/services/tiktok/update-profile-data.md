---
type: Service
title: TikTok update profile data
description: Transforms a raw TikTok userInfo payload into profile attributes.
tags: [ingestion, metrics, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-update-profile-data
    title: TiktokServices::UpdateProfileData
    resource: ../../../app/services/tiktok_services/update_profile_data.rb
---

# Behavior

- Requires `userInfo` with a `user` object. Missing values default to empty hashes and then to nil or zero.[^tiktok-update-profile-data]
- Maps `uniqueId` to both `username` and `unique_id`. Maps `secUid` to `sec_uid`, which the posts service needs.[^tiktok-update-profile-data]
- Counts are read from `userInfo.stats` through `safe_integer`. `hearts` falls back to `heart`.[^tiktok-update-profile-data]
- Stores the full payload in `data` for archiving. The result feeds the [TikTok profile](/tiktok/profile.md) model.[^tiktok-update-profile-data]
