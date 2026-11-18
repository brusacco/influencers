---
type: Service
title: Scrape.do task lock
description: Non-blocking filesystem lock that prevents overlapping executions of each scheduled Scrape.do batch task.
tags: [ingestion, scheduling, concurrency]
generated:
  by: process:codex
  at: 2026-11-18T08:15:00Z
sources:
  - id: scrape-do-task-lock
    title: Scrape.do task lock helper
    resource: ../../../lib/tasks/instagram/scrape_do_task_lock.rb
  - id: instagram-update-posts
    title: Instagram general posts task
    resource: ../../../lib/tasks/instagram/update_posts.rake
  - id: instagram-update-news-posts
    title: Instagram news posts task
    resource: ../../../lib/tasks/instagram/update_news_posts_scrape_do_graphql.rake
  - id: instagram-update-profiles
    title: Instagram profiles task
    resource: ../../../lib/tasks/instagram/update_profiles.rake
---

# Behavior

Each Scrape.do batch task attempts an exclusive non-blocking lock in the system
temporary directory before it starts.[^scrape-do-task-lock] If the same task is
already running, the new invocation prints a skip message and exits without
making provider requests.[^instagram-update-posts][^instagram-update-news-posts][^instagram-update-profiles]

Locks are released on normal completion and through `ensure` when the task
raises. Locks are task-specific, so the staggered profile, general-post, and
news-post tasks can still run independently when their schedules permit. See
the [ingestion schedule](/business/ingestion-schedule.md) for their run times.
