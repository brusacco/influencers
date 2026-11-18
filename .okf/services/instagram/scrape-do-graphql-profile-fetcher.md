---
type: Service
title: Scrape.do GraphQL profile fetcher
description: Retrieves the public Instagram profile root through Scrape.do API GET and POST requests.
tags: [ingestion, services]
generated:
  by: process:codex
  at: 2026-11-18T06:30:00Z
sources:
  - id: scrape-do-graphql-profile-fetcher
    title: InstagramServices::ScrapeDoGraphqlProfileFetcher
    resource: ../../../app/services/instagram_services/scrape_do_graphql_profile_fetcher.rb
  - id: update-profiles-task
    title: Instagram profile update task
    resource: ../../../lib/tasks/instagram/update_profiles.rake
---

# Behavior

- `ScrapeDoGraphqlProfileFetcher.call(username)` gets the public profile page through Scrape.do, extracts `PolarisLoggedOutMobileProfileRootQuery`, then posts that query back to Instagram through Scrape.do.[^scrape-do-graphql-profile-fetcher]
- It returns the public profile root, which currently contains follower and following counts, name, biography, verification, privacy, profile picture URL, and the numeric profile key.[^scrape-do-graphql-profile-fetcher]
- It never sends the application host directly to Instagram.

# Operational use

`instagram:update_profiles` processes enabled Paraguayan profiles in follower-descending order through this fetcher. `INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT` provides a bounded smoke test.[^update-profiles-task]
