---
type: Process
title: Ingestion schedule
description: The recurring Whenever jobs that refresh profiles, posts, and stats, with the profile set each one reads.
tags: [scheduling, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T09:45:00Z
sources:
  - id: schedule
    title: Whenever schedule
    resource: ../../config/schedule.rb
  - id: instagram-update-profiles
    title: Instagram update profiles task
    resource: ../../lib/tasks/instagram/update_profiles.rake
  - id: instagram-update-posts
    title: Instagram update posts task
    resource: ../../lib/tasks/instagram/update_posts.rake
  - id: instagram-update-posts-ferrum
    title: Instagram Ferrum update posts task
    resource: ../../lib/tasks/instagram/update_posts_ferrum.rake
  - id: instagram-update-news-posts
    title: Instagram update news posts task
    resource: ../../lib/tasks/instagram/update_news_posts.rake
  - id: instagram-update-post-marcas
    title: Instagram update brand posts task
    resource: ../../lib/tasks/instagram/update_post_marcas.rake
  - id: instagram-update-profiles-stats
    title: Instagram update profile stats task
    resource: ../../lib/tasks/instagram/update_profiles_stats.rake
  - id: instagram-create-daily-stats
    title: Instagram create daily stats task
    resource: ../../lib/tasks/instagram/create_daily_stats.rake
  - id: tiktok-update-posts
    title: TikTok update posts task
    resource: ../../lib/tasks/tiktok/update_posts.rake
  - id: tiktok-crawler
    title: TikTok crawler task
    resource: ../../lib/tasks/tiktok/crawler.rake
---

# Schedule

`config/schedule.rb` is the source of truth for these jobs.[^schedule]

- Every 4 hours at minute 05: `instagram:update_news_posts`, which delegates to the Scrape.do GraphQL news updater for enabled Paraguayan `medio` profiles.[^schedule][^instagram-update-news-posts]
- Every 8 hours at 01:00, 09:00, and 17:00: `instagram:update_posts`, which uses Scrape.do API GraphQL for non-`medio` `tracked` profiles. News profiles are exclusively refreshed by `instagram:update_news_posts`.[^schedule][^instagram-update-posts]
- Every 12 hours at 04:00 and 16:00: `instagram:update_profiles_stats`, which reads enabled Paraguayan profiles.[^schedule][^instagram-update-profiles-stats]
- Daily: `instagram:update_profiles` at 00:30; `instagram:create_daily_stats` at 02:00; `tiktok:update_posts` at 02:20; `util:collaborations` at 05:00; and `util:add_mentions_profiles` at 05:30. The profile refresh uses Scrape.do API GraphQL for enabled Paraguayan profiles and defaults to five workers.[^schedule][^instagram-update-profiles][^instagram-create-daily-stats][^tiktok-update-posts]

# Not scheduled

`instagram:update_posts_ferrum` remains available as an explicit manual
fallback. It uses a direct, unauthenticated Chrome session by default and reads
the visible post batch with one internal GraphQL query from that session. It can
optionally route the same browser through Scrape.do for comparison. Set
`INSTAGRAM_FERRUM_PROFILE_LIMIT` to a positive number for a bounded smoke test.[^instagram-update-posts-ferrum]
`instagram:update_news_posts_scrape_do_graphql` remains as the direct technical
entry point behind the scheduled `instagram:update_news_posts` task. Pass
`CHECK_INACTIVE=1` to additionally verify disabled media profiles: the task
enables each one as it begins processing, then disables it if Instagram does
not expose the public post-grid query. Set
`INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT` for a bounded production smoke test before
considering it as a replacement for the scheduled news updater.
`instagram:update_missing_posted_at` is an unscheduled, detail-query backfill
for posts whose publication date is missing. It supports
`INSTAGRAM_SCRAPE_DO_POST_LIMIT` and `INSTAGRAM_SCRAPE_DO_CONCURRENCY` and is
kept manual because it makes two provider requests per post.
`instagram:update_posts_marcas` exists for brand posts but is not in the
schedule.[^instagram-update-post-marcas] The TikTok crawler is also
unscheduled.[^tiktok-crawler]

# Load notes

The profile and post refresh tasks default to five workers and wait `FERRUM_PAUSE_SECONDS` between profiles per worker. `INSTAGRAM_SCRAPE_DO_CONCURRENCY` can set any Scrape.do task's worker count from 1 through 10.[^instagram-update-profiles][^instagram-update-posts][^instagram-update-news-posts] Each uses a non-blocking task-specific lock so a delayed run cannot overlap its next scheduled invocation. The scheduled times are staggered so Instagram collectors do not start together. Changes to this schedule change provider quota use and data freshness, so explain them before editing.
