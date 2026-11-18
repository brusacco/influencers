---
type: Service
title: Scrape.do GraphQL post upserter
description: Maps one Scrape.do GraphQL grid node to a safe partial Instagram post update.
tags: [ingestion, services, experimental]
generated:
  by: process:codex
  at: 2026-11-18T10:00:00Z
sources:
  - id: scrape-do-graphql-post-upserter
    title: InstagramServices::ScrapeDoGraphqlPostUpserter
    resource: ../../../app/services/instagram_services/scrape_do_graphql_post_upserter.rb
  - id: ferrum-post-upserter
    title: InstagramServices::FerrumPostUpserter
    resource: ferrum-post-upserter.md
  - id: scrape-do-graphql-post-timestamp-fetcher
    title: Scrape.do GraphQL post timestamp fetcher
    resource: scrape-do-graphql-post-timestamp-fetcher.md
---

# Behavior

- `ScrapeDoGraphqlPostUpserter.call(profile, node)` maps a grid node's shortcode, public URL, media type, product type, caption, and visible likes to partial post attributes.[^scrape-do-graphql-post-upserter]
- It delegates persistence to [Ferrum post upserter](ferrum-post-upserter.md), preserving values that the profile-grid query does not expose and storing compact diagnostic metadata at `data['ferrum']`.[^scrape-do-graphql-post-upserter][^ferrum-post-upserter]
- If the persisted post lacks `posted_at`, it invokes the [post timestamp fetcher](scrape-do-graphql-post-timestamp-fetcher.md) to retrieve and store the exact `taken_at` time. Posts that already have a date skip this extra request.[^scrape-do-graphql-post-upserter][^scrape-do-graphql-post-timestamp-fetcher]
- It is used by both scheduled post collectors and the manual GraphQL import tasks.
