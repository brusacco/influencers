---
type: Service
title: Instagram base service
description: Shared Scrape.do request, retry, username validation, and error types for Instagram services.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: instagram-base
    title: InstagramServices::Base
    resource: ../../../app/services/instagram_services/base.rb
---

# Responsibilities

- Validates the username: non-blank, `\A[\w.]+\z`, at most 30 characters.[^instagram-base]
- Builds the `web_profile_info` URL and wraps it in the Scrape.do proxy URL, which carries the token as a query parameter.[^instagram-base]
- Retries temporary network failures: up to 3 retries (4 attempts total), with 2, 4, and 8 second backoff. The rescued errors are timeouts, `ECONNREFUSED`, `EHOSTUNREACH`, and `SocketError`.[^instagram-base]
- Maps HTTP status codes in `make_request`: 404 becomes "Profile not found", 429 becomes "Rate limit exceeded", 5xx becomes a server error, and any other code becomes a generic HTTP error. All of these raise `APIError`.[^instagram-base]
- Defines `InvalidUsernameError`, `APIError`, `TimeoutError`, and `ParseError`. Subclasses rescue these and return them through `handle_error`.[^instagram-base]

# Gotcha

`APIError` is not in the retry list. A 429 or 5xx response is therefore never retried, even though the 429 path is a rate limit. Only the network-level errors listed above get retries.[^instagram-base]
