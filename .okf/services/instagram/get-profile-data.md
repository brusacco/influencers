---
type: Service
title: Instagram get profile data
description: Fetches an Instagram profile payload by username and checks that the user object exists.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T09:15:00Z
sources:
  - id: instagram-get-profile-data
    title: InstagramServices::GetProfileData
    resource: ../../../app/services/instagram_services/get_profile_data.rb
  - id: scrape-do-graphql-profile-fetcher
    title: Scrape.do GraphQL profile fetcher
    resource: ../../../app/services/instagram_services/scrape_do_graphql_profile_fetcher.rb
---

# Behavior

- `GetProfileData.call(username)` fetches the public profile through the [Scrape.do GraphQL profile fetcher](scrape-do-graphql-profile-fetcher.md), not the retired web-profile endpoint.[^instagram-get-profile-data][^scrape-do-graphql-profile-fetcher]
- It adapts the GraphQL fields into the legacy `data.user` shape (`edge_followed_by`, `edge_follow`, profile fields, and flags), preserving compatibility with [Update profile data](update-profile-data.md), callbacks, and operational tasks.[^instagram-get-profile-data]
- Invalid usernames and provider failures return `handle_error(message)`. Unexpected errors are logged with the first five backtrace lines and return a generic error.[^instagram-get-profile-data]
- The current public profile query does not expose `edge_related_profiles`; consumers of that retired field receive no related-profile edges.[^instagram-get-profile-data]

The result feeds [Update profile data](update-profile-data.md), and the failure messages feed the [error classifier](error-classifier.md).
