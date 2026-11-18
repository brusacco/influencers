---
type: Service
title: Instagram Ferrum posts fetcher
description: Collects public Instagram post metadata with a direct browser session or optional Scrape.do Proxy Mode.
tags: [ingestion, services]
generated:
  by: process:codex
  at: 2026-11-18T03:00:00Z
sources:
  - id: ferrum-posts-fetcher
    title: InstagramServices::FerrumPostsFetcher
    resource: ../../../app/services/instagram_services/ferrum_posts_fetcher.rb
  - id: instagram-config
    title: Instagram configuration
    resource: ../../../config/initializers/instagram_config.rb
---

# Behavior

- `FerrumPostsFetcher.call(profile)` creates a fresh, direct Ferrum browser context by default, without an authenticated Instagram session. Setting `INSTAGRAM_FERRUM_USE_PROXY=true` routes the same context through Scrape.do Proxy Mode; its timeout and per-profile post limit remain configurable.[^ferrum-posts-fetcher][^instagram-config]
- The collector loads a profile once, then executes the profile's preloaded GraphQL posts query inside that same browser session. It returns visible post codes, captions, media data, and `like_count` when Instagram exposes them.[^ferrum-posts-fetcher]
- A profile that exposes no post links is a failed fetch, not a successful zero-post update. This protects existing records from being treated as fresh when Instagram serves a login-limited public view.[^ferrum-posts-fetcher]
- The task is deliberately sequential and rate-limited; it is documented in [ingestion schedule](/business/ingestion-schedule.md). `INSTAGRAM_FERRUM_PROFILE_LIMIT` can constrain a manual run to a positive number of highest-follower tracked profiles for an operational smoke test.

# Operational limitation

Instagram may change the public page or its internal GraphQL query at any time, and proxy IPs may receive a login-limited view. The query currently does not expose comment counts or publication dates, so the upserter preserves any existing values for those fields. The service reports an empty post response as a failed fetch and remains a manual fallback rather than a scheduled job.
