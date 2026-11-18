---
type: Service
title: TikTok base service
description: Shared tikAPI.io request, parsing, retry, and timestamp helpers for TikTok services.
tags: [ingestion, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: tiktok-base
    title: TiktokServices::Base
    resource: ../../../app/services/tiktok_services/base.rb
---

# Responsibilities

- `make_request` calls `TikTokConfig::API_BASE_URL` with the `X-API-KEY` header and the configured timeout. It maps 400, 401, 404, 429, and 5xx responses to `APIError` with the provider message.[^tiktok-base]
- `make_request` converts timeouts to `TimeoutError` and connection failures to `APIError` before returning to the caller.[^tiktok-base]
- `with_retry` retries up to `TikTokConfig::MAX_RETRIES` times with 2, 4, and 8 second backoff.[^tiktok-base]
- `parse_response` turns JSON parse failures into `ParseError`. `parse_timestamp` returns nil for a nil timestamp.[^tiktok-base]

# Gotcha

`make_request` runs inside the `with_retry` block and converts the raw network exceptions to `TimeoutError` and `APIError`. `with_retry` rescues only the raw exceptions, so it never sees a timeout or connection error and never retries it. The retry wrapper is effectively inactive for network failures. Fixing it means rescuing the converted errors in `with_retry` or moving the conversion out of `make_request`.[^tiktok-base]
