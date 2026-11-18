---
type: Service
title: Instagram get posts data
description: Compatibility wrapper that fetches public GraphQL media nodes for an Instagram profile.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T09:15:00Z
sources:
  - id: instagram-get-posts-data
    title: InstagramServices::GetPostsData
    resource: ../../../app/services/instagram_services/get_posts_data.rb
  - id: scrape-do-graphql-posts-fetcher
    title: Scrape.do GraphQL posts fetcher
    resource: ../../../app/services/instagram_services/scrape_do_graphql_posts_fetcher.rb
---

# Behavior

- `GetPostsData.call(profile)` requires a profile with a non-blank username and delegates to the [Scrape.do GraphQL posts fetcher](scrape-do-graphql-posts-fetcher.md).[^instagram-get-posts-data][^scrape-do-graphql-posts-fetcher]
- Returns the current GraphQL media nodes. Consumers persist them through [Scrape.do GraphQL post upserter](scrape-do-graphql-post-upserter.md), rather than the retired edge transformer.[^instagram-get-posts-data]
- It forwards fetch errors through `handle_error(message)`.[^instagram-get-posts-data]
