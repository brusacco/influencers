---
type: Process
title: Ingestion schedule
description: The recurring Whenever jobs that refresh profiles, posts, and stats, with the profile set each one reads.
tags: [scheduling, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-18T06:45:00Z
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

- Every 3 hours: `instagram:update_news_posts`, which delegates to the sequential Scrape.do GraphQL news updater for enabled Paraguayan `medio` profiles.[^schedule][^instagram-update-news-posts]
- Every 6 hours: `instagram:update_posts`, which uses Scrape.do API GraphQL for `tracked` profiles.[^schedule][^instagram-update-posts]
- Every 12 hours: `instagram:update_profiles_stats`, which reads enabled Paraguayan profiles.[^schedule][^instagram-update-profiles-stats]
- Every 24 hours: `instagram:update_profiles`, `util:collaborations`, and `util:add_mentions_profiles`. The profile refresh uses Scrape.do API GraphQL for enabled Paraguayan profiles.[^schedule][^instagram-update-profiles]
- Daily at 00:00: `instagram:create_daily_stats`, which records follower counts for `tracked` profiles, and `tiktok:update_posts`.[^schedule][^instagram-create-daily-stats][^tiktok-update-posts]

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
`instagram:update_posts_marcas` exists for brand posts but is not in the
schedule.[^instagram-update-post-marcas] The TikTok crawler is also
unscheduled.[^tiktok-crawler]

# Load notes

The profile refresh is sequential and waits `FERRUM_PAUSE_SECONDS` between profiles, reducing concurrent requests but increasing the end-to-end completion time.[^instagram-update-profiles] Post refresh for `tracked` profiles follows the same sequential pause.[^instagram-update-posts] Changes to this schedule change provider quota use and data freshness, so explain them before editing.
