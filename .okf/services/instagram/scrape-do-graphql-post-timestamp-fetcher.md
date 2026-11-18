---
type: Service
title: Scrape.do GraphQL post timestamp fetcher
description: Retrieves publication time, comments, and visible likes for one public Instagram post through its detail query.
tags: [ingestion, services, graphql]
generated:
  by: process:codex
  at: 2026-11-18T11:00:00Z
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
service retrieves the canonical public post page through Scrape.do, extracts
`PolarisLoggedOutDesktopWWWPostRootContentQuery`, and sends that detail query
through Scrape.do to retrieve `taken_at`, `comment_count`, and visible
`like_count` for the requested shortcode. It also retains compact compatible
metadata for the author, coauthors, user tags, location, caption metadata,
dimensions, and visibility flags; it intentionally excludes carousel media and
other large nested structures.[^scrape-do-graphql-post-timestamp-fetcher]

It deliberately constructs `/p/:shortcode/` for feed and carousel media and
`/reel/:shortcode/` for `clips`, `reel`, or `reels` product types instead of
reusing the stored URL. Historical URLs that include the profile username can
expose a different mobile or landing query and omit the detail timestamp.[^scrape-do-graphql-post-timestamp-fetcher]

When Instagram exposes no public detail query, the service writes a
shortcode-specific `Rails.cache` entry for 30 days. Production uses Redis for
that cache, so later scheduled runs defer the retry without modifying
`instagram_posts`. Network, proxy, parsing, and GraphQL-response failures are
not cached and continue to use normal retries.[^scrape-do-graphql-post-timestamp-fetcher]

The regular GraphQL post upserter invokes this service automatically for a new
or existing post whose `posted_at` is null. `instagram:update_missing_posted_at`
is the manual backfill task for dates that remain missing; it selects only posts
where `posted_at` is null, prioritizes descending IDs, and caps each run at
1,000 posts. `INSTAGRAM_SCRAPE_DO_POST_LIMIT` can select a smaller batch and
`INSTAGRAM_SCRAPE_DO_CONCURRENCY` controls workers.[^scrape-do-graphql-post-timestamp-fetcher][^instagram-update-missing-posted-at]

The task is intentionally unscheduled because each post needs two provider
requests. It has its own non-blocking lock, so overlapping invocations do not
make duplicate requests.[^instagram-update-missing-posted-at]
