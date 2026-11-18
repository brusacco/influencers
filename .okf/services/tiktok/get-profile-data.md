---
type: Service
title: TikTok get profile data
description: Checks a TikTok username through the public check endpoint and validates the user structure.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-get-profile-data
    title: TiktokServices::GetProfileData
    resource: ../../../app/services/tiktok_services/get_profile_data.rb
---

# Behavior

- `GetProfileData.call(username:)` validates the username with the same pattern as Instagram, then calls `/public/check` through [Base](base.md) with retry.[^tiktok-get-profile-data]
- A status other than `success` or `0` raises `APIError`. A missing `userInfo` raises `APIError`. A missing `userInfo.user` raises `ParseError`.[^tiktok-get-profile-data]
- Returns the raw payload on success. [Update profile data](update-profile-data.md) maps it to attributes.[^tiktok-get-profile-data]
