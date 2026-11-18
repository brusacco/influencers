---
type: Service
title: Scrape.do GraphQL posts fetcher
description: Experimental, non-persisting collector that obtains an Instagram profile's post grid through Scrape.do API GET and POST requests.
tags: [ingestion, services, experimental]
generated:
  by: process:codex
  at: 2026-11-18T05:00:00Z
sources:
  - id: scrape-do-graphql-posts-fetcher
    title: InstagramServices::ScrapeDoGraphqlPostsFetcher
    resource: ../../../app/services/instagram_services/scrape_do_graphql_posts_fetcher.rb
  - id: scrape-do-graphql-posts-probe
    title: Scrape.do GraphQL posts probe task
    resource: ../../../lib/tasks/instagram/probe_posts_scrape_do_graphql.rake
  - id: scrape-do-graphql-posts-import
    title: Scrape.do GraphQL posts import task
    resource: ../../../lib/tasks/instagram/import_posts_scrape_do_graphql.rake
  - id: scrape-do-graphql-posts-update
    title: Scrape.do GraphQL posts update task
    resource: ../../../lib/tasks/instagram/update_posts_scrape_do_graphql.rake
  - id: scrape-do-graphql-news-update
    title: Scrape.do GraphQL news posts update task
    resource: ../../../lib/tasks/instagram/update_news_posts_scrape_do_graphql.rake
---

# Behavior

- `ScrapeDoGraphqlPostsFetcher.call(username)` first retrieves the public profile page through Scrape.do's residential API and extracts `PolarisProfilePostsLoggedOutTabGridUIContentQuery` plus its current document ID and variables.[^scrape-do-graphql-posts-fetcher]
- It sends the corresponding form-encoded POST to Instagram's `/api/graphql/` endpoint through Scrape.do, including the app and friendly-name headers required by the public query.[^scrape-do-graphql-posts-fetcher]
- The current response exposes media primary keys (`pk`) but can omit shortcodes. The fetcher converts those primary keys with Instagram's URL-safe base-64 alphabet before returning up to the configured post limit.[^scrape-do-graphql-posts-fetcher]
- `instagram:probe_posts_scrape_do_graphql[username]` only prints the extracted shortcodes. It does not create or update records and is deliberately unscheduled while the provider behavior is being evaluated.[^scrape-do-graphql-posts-probe]
- `instagram:import_posts_scrape_do_graphql[username]` persists one fetched grid through `ScrapeDoGraphqlPostUpserter`, which delegates to the partial-update behavior of `FerrumPostUpserter`. It stores the raw node under `data['ferrum']` and does not erase fields absent from the grid response.[^scrape-do-graphql-posts-import]
- `instagram:update_posts_scrape_do_graphql[username]` is the production-facing alias for one explicit profile import. It refuses to run without a username and is not scheduled.[^scrape-do-graphql-posts-update]
- `instagram:update_news_posts_scrape_do_graphql` selects Paraguayan `medio` profiles whether enabled or disabled. It enables each profile as it begins processing, is sequential and unscheduled, and supports `INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT` for a bounded production smoke test.[^scrape-do-graphql-news-update]

# Operational status

The flow was manually verified for `ueno_py` on 2026-11-18, returning 12 post shortcodes. It avoids direct Instagram traffic from the application host, but is experimental and must be observed for proxy response variance before it replaces the scheduled post updater.
