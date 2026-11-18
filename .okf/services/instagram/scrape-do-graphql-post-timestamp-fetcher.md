---
type: Service
title: Scrape.do GraphQL post timestamp fetcher
description: Retrieves publication time, comments, and visible likes for one public Instagram post through its detail query.
tags: [ingestion, services, graphql]
generated:
  by: process:codex
  at: 2026-11-18T09:45:00Z
sources:
  - id: scrape-do-graphql-post-timestamp-fetcher
    title: InstagramServices::ScrapeDoGraphqlPostTimestampFetcher
    resource: ../../../app/services/instagram_services/scrape_do_graphql_post_timestamp_fetcher.rb
  - id: instagram-update-missing-posted-at
    title: Instagram missing publication date task
    resource: ../../../lib/tasks/instagram/update_missing_posted_at.rake
---

# Behavior

The profile-grid GraphQL response omits the exact publication timestamp. This
service retrieves the public post page through Scrape.do, extracts
`PolarisLoggedOutDesktopWWWPostRootContentQuery`, and sends that detail query
through Scrape.do to retrieve `taken_at`, `comment_count`, and visible
`like_count` for the requested shortcode. It also retains compact compatible
metadata for the author, coauthors, user tags, location, caption metadata,
dimensions, and visibility flags; it intentionally excludes carousel media and
other large nested structures.[^scrape-do-graphql-post-timestamp-fetcher]

The regular GraphQL post upserter invokes this service automatically for a new
or existing post whose `posted_at` is null. `instagram:update_missing_posted_at`
is the manual backfill task for dates that remain missing; it selects only posts
where `posted_at` is null, prioritizes descending IDs, and caps each run at
1,000 posts. `INSTAGRAM_SCRAPE_DO_POST_LIMIT` can select a smaller batch and
`INSTAGRAM_SCRAPE_DO_CONCURRENCY` controls workers.[^scrape-do-graphql-post-timestamp-fetcher][^instagram-update-missing-posted-at]

The task is intentionally unscheduled because each post needs two provider
requests. It has its own non-blocking lock, so overlapping invocations do not
make duplicate requests.[^instagram-update-missing-posted-at]
