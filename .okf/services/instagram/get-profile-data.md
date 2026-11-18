---
type: Service
title: Instagram get profile data
description: Fetches an Instagram profile payload by username and checks that the user object exists.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: instagram-get-profile-data
    title: InstagramServices::GetProfileData
    resource: ../../../app/services/instagram_services/get_profile_data.rb
---

# Behavior

- `GetProfileData.call(username)` fetches the payload through [Base](base.md) and checks that it is a Hash with `data.user`.[^instagram-get-profile-data]
- A missing user with a "user not found" message raises `InvalidUsernameError`. Any other missing user raises `ParseError`.[^instagram-get-profile-data]
- Known errors return `handle_error(message)`. Unexpected errors are logged with the first five backtrace lines and then return a generic error.[^instagram-get-profile-data]

The result feeds [Update profile data](update-profile-data.md), and the failure messages feed the [error classifier](error-classifier.md).
