---
type: Service
title: Instagram Ferrum post upserter
description: Persists browser-collected Instagram metadata while preserving fields the public page did not expose.
tags: [ingestion, services]
generated:
  by: process:codex
  at: 2026-11-18T06:00:00Z
sources:
  - id: ferrum-post-upserter
    title: InstagramServices::FerrumPostUpserter
    resource: ../../../app/services/instagram_services/ferrum_post_upserter.rb
  - id: instagram-post
    title: Instagram post model
    resource: /instagram/post.md
---

# Behavior

- `FerrumPostUpserter.call(profile, attributes)` finds or initializes an [Instagram post](/instagram/post.md) by shortcode.[^ferrum-post-upserter][^instagram-post]
- It assigns only non-nil public-page attributes and merges compact diagnostic metadata under `data['ferrum']`. It retains identifiers, media type, canonical/display URLs, and visible-like state, but discards nested carousel and image-version payloads so the serialized `data` column remains within its storage limit. Missing counters therefore do not erase previously ingested values.[^ferrum-post-upserter]
- It does not download images: media downloads would introduce additional direct requests outside the browser proxy path.[^ferrum-post-upserter]
