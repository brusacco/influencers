---
type: Service
title: Scrape.do GraphQL profile upserter
description: Applies public profile-root fields while preserving attributes GraphQL does not expose.
tags: [ingestion, services]
generated:
  by: process:codex
  at: 2026-11-18T06:30:00Z
sources:
  - id: scrape-do-graphql-profile-upserter
    title: InstagramServices::ScrapeDoGraphqlProfileUpserter
    resource: ../../../app/services/instagram_services/scrape_do_graphql_profile_upserter.rb
---

# Behavior

- Maps `follower_count`, `following_count`, public profile identity fields, and `pk` to the normalized [Instagram profile](/instagram/profile.md).[^scrape-do-graphql-profile-upserter]
- Only assigns fields present in the GraphQL response; category and professional-account fields unavailable in this query retain their existing values.[^scrape-do-graphql-profile-upserter]
