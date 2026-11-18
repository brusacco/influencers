---
type: Service
title: Instagram update profile data
description: Transforms a raw Instagram user payload into profile attributes.
tags: [ingestion, metrics, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: instagram-update-profile-data
    title: InstagramServices::UpdateProfileData
    resource: ../../../app/services/instagram_services/update_profile_data.rb
---

# Behavior

- Requires `data.user` and these keys: `edge_followed_by`, `edge_follow`, `profile_pic_url`, `is_private`, `is_verified`, `full_name`, `biography`, `is_embeds_disabled`, and `id`. Missing keys fail the call.[^instagram-update-profile-data]
- Counts come from `edge_followed_by.count` and `edge_follow.count`, and default to 0.[^instagram-update-profile-data]
- Maps the user into the attributes of the [Instagram profile](/instagram/profile.md). The Instagram `id` becomes `uid`. Optional category and account flags fall back to defaults.[^instagram-update-profile-data]
