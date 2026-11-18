---
type: Service
title: Instagram error classifier
description: Classifies Instagram service error messages as permanent, temporary, or unknown to decide whether a profile is disabled.
tags: [ingestion, errors, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: instagram-error-classifier
    title: InstagramServices::ErrorClassifier
    resource: ../../../app/services/instagram_services/error_classifier.rb
---

# Behavior

- `classify` checks permanent patterns first, then temporary patterns, and otherwise returns `:unknown`. Permanent patterns include `404`, `not found`, `deleted`, and `user not found on instagram`.[^instagram-error-classifier]
- Temporary patterns include `timeout`, `network error`, `connection`, `rate limit`, `429`, and `attempts failed`.[^instagram-error-classifier]
- `describe` returns `disable_profile` for permanent errors and `retry_later` for temporary ones. Unknown errors are logged and do not disable the profile.[^instagram-error-classifier]

# Gotcha

Matching is substring-based and case-insensitive. The permanent check runs first, so a message that contains both a permanent and a temporary pattern is classified as permanent. Any change to the wording in [Base](base.md) can change how a profile is handled.[^instagram-error-classifier]
