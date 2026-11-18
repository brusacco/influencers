---
type: Service
title: TikTok error classifier
description: Classifies TikTok service error messages as permanent, temporary, or unknown.
tags: [ingestion, errors, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-error-classifier
    title: TiktokServices::ErrorClassifier
    resource: ../../../app/services/tiktok_services/error_classifier.rb
---

# Behavior

- `describe` takes a message string. Permanent regex matches include `user not found`, `profile not found`, `account banned`, and `account deleted`. Temporary matches include `rate limit`, `timeout`, `network error`, `temporary`, and 502, 503, and 504.[^tiktok-error-classifier]
- Permanent errors return `disable_profile`. Temporary errors return `retry_later`. Anything else returns `:unknown` with `retry: true`.[^tiktok-error-classifier]

# Gotcha

The comment on the unknown default says "treat as temporary", but the returned type is `:unknown`. Callers must check `retry`, not compare the type with `:temporary`. Unlike the [Instagram classifier](../instagram/error-classifier.md), there is no `classify` method, so the two classifiers have different interfaces.[^tiktok-error-classifier]
