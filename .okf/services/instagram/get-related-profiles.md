---
type: Service
title: Instagram get related profiles
description: Extracts related Instagram usernames from the edge_related_profiles structure.
tags: [collaborations, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: instagram-get-related-profiles
    title: InstagramServices::GetRelatedProfiles
    resource: ../../../app/services/instagram_services/get_related_profiles.rb
---

# Behavior

- Returns the `node.username` values from `data.user.edge_related_profiles.edges`. Edges without a username are skipped.[^instagram-get-related-profiles]
- A missing or non-array edge list returns an empty list, not an error.[^instagram-get-related-profiles]
- Feeds the [Instagram collaboration](/instagram/collaboration.md) records.[^instagram-get-related-profiles]
