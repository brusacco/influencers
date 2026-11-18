---
type: Business Rule
title: Collaboration detection
description: The rules that turn co-authored Instagram posts into collaboration records between Paraguayan profiles.
tags: [business-rules, collaborations]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: collaborations-task
    title: Generate collaborations task
    resource: ../../lib/tasks/util/collaborations.rake
  - id: profile-model
    title: Profile model
    resource: ../../app/models/profile.rb
---

# Rules

The task runs over `InstagramPost.a_month_ago`. A post is considered only if all of these hold.[^collaborations-task]

- No collaboration already exists for the post.
- The post data is not empty.
- The poster has at least 40,000 followers.
- The poster is in Paraguay and enabled.
- The post data contains `coauthor_producers`.[^collaborations-task]

For each co-author username other than the poster, the task finds or creates a `Profile` and creates an [InstagramCollaboration](/instagram/collaboration.md) dated at the post's `posted_at`.[^collaborations-task]

# Gotchas

- Creating a missing co-author profile triggers the profile's remote fetch on create. Each new co-author therefore adds external calls. See the [Instagram profile model](/instagram/profile.md).[^profile-model]
- The skip guard checks the post, not each co-author. If a run fails partway through a post, a rerun skips that post and the missing co-author links are not backfilled.[^collaborations-task]
- Errors for a single co-author are printed and swallowed, so the rest of the post continues.[^collaborations-task]
- The 40,000 floor is separate from the 10,000 `tracked` floor. See [profile qualification](/business/profile-qualification.md).
