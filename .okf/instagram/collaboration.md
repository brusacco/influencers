---
type: Model
title: Instagram collaboration model
description: Records that a collaborator profile appeared with a collaborated profile on a specific post.
tags: [collaborations]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: collaboration-model
    title: InstagramCollaboration model
    resource: ../../app/models/instagram_collaboration.rb
  - id: collaborations-schema
    title: instagram_collaborations table schema
    resource: ../../db/schema.rb
---

# Overview

`InstagramCollaboration` links two [profiles](/instagram/profile.md), a `collaborator` and a `collaborated`, through the [post](/instagram/post.md) where they appeared.[^collaboration-model]

# Schema

Columns: `instagram_post_id`, `collaborator_id`, `collaborated_id`, and `posted_at`. Indexes exist on each profile ID with `posted_at`, and on `instagram_post_id` with `collaborator_id`.[^collaborations-schema]

# Behavior

- Belongs to the post with `touch: true`, so a new collaboration refreshes the post's timestamp.[^collaboration-model]
- The table has no foreign key constraints and the model has no uniqueness validation. Duplicate pairs are not blocked at the database level.[^collaborations-schema]
