---
type: Concern
title: Image downloader concern
description: Concern that downloads a remote image into an Active Storage attachment with optional placeholder fallback.
tags: [media, ingestion]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: image-downloader
    title: ImageDownloader concern
    resource: ../../app/models/concerns/image_downloader.rb
---

# Overview

`download_and_attach_image` fetches a URL with HTTParty and attaches the body to a named Active Storage attachment.[^image-downloader]

# Behavior

- Returns `false` without a request when the attachment is already set or the URL is blank.
- On failure, logs a warning. If a `placeholder_url` is given, it attaches that instead.
- Returns `true` on success and `false` otherwise.[^image-downloader]

# Notes

The HTTParty call sets no explicit timeout. External calls are fallible, so add one before reusing this concern in new paths.

# Used by

[TikTok profile](/tiktok/profile.md) for avatars and [TikTok post](/tiktok/post.md) for covers.
