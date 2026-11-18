---
type: Business Rule
title: Automatic profile disabling policy
description: When ingestion tasks switch a profile to disabled, and when they deliberately leave it enabled.
tags: [business-rules, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: instagram-update-profiles
    title: Instagram update profiles task
    resource: ../../lib/tasks/instagram/update_profiles.rake
  - id: tiktok-update-profiles
    title: TikTok update profiles task
    resource: ../../lib/tasks/tiktok/update_profiles.rake
  - id: tiktok-update-posts
    title: TikTok update posts task
    resource: ../../lib/tasks/tiktok/update_posts.rake
  - id: check-profile-task
    title: Instagram check profile task
    resource: ../../lib/tasks/instagram/check_profile.rake
---

# Overview

Disabling is the only automatic lifecycle change ingestion makes to a profile. It is driven by the error classification of the provider call.[^instagram-update-profiles]

# Rules

- A permanent provider error sets `enabled` to false. Instagram and TikTok profile refreshes both do this.[^instagram-update-profiles][^tiktok-update-profiles]
- A temporary or unknown error leaves `enabled` unchanged. The code is intentionally conservative.[^instagram-update-profiles]
- A TikTok exception whose message classifies as permanent also disables the profile. Other exceptions are only logged.[^tiktok-update-profiles]
- The TikTok posts task has its own disable branch.[^tiktok-update-posts]
- An Instagram profile with no stored `data` is skipped rather than fetched.[^instagram-update-profiles]

# Re-enabling

Re-enabling is manual. The operator runs `Profile.find(id).update!(enabled: true)` as the check task suggests, or uses the admin form.[^check-profile-task] See [Instagram profiles admin](/admin/instagram-profiles-admin.md).

# Notes

Disabling removes a profile from every enabled-based set at once, including `tracked`, so its posts and stats stop updating. Classification rules live in the [Instagram error classifier](/services/instagram/error-classifier.md) and the [TikTok error classifier](/services/tiktok/error-classifier.md).
