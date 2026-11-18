---
type: Service
title: Scrape.do GraphQL post upserter
description: Maps one Scrape.do GraphQL grid node to a safe partial Instagram post update.
tags: [ingestion, services, experimental]
generated:
  by: process:codex
  at: 2026-11-18T03:45:00Z
sources:
  - id: scrape-do-graphql-post-upserter
    title: InstagramServices::ScrapeDoGraphqlPostUpserter
    resource: ../../../app/services/instagram_services/scrape_do_graphql_post_upserter.rb
  - id: ferrum-post-upserter
    title: InstagramServices::FerrumPostUpserter
    resource: ferrum-post-upserter.md
---

# Behavior

- `ScrapeDoGraphqlPostUpserter.call(profile, node)` maps a grid node's shortcode, public URL, media type, product type, caption, and visible likes to partial post attributes.[^scrape-do-graphql-post-upserter]
- It delegates persistence to [Ferrum post upserter](ferrum-post-upserter.md), preserving values that the profile-grid query does not expose and storing the raw node at `data['ferrum']`.[^scrape-do-graphql-post-upserter][^ferrum-post-upserter]
- It is used only by the manual `instagram:import_posts_scrape_do_graphql[username]` task while the API-only collection flow remains under evaluation.
