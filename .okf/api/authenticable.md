---
type: Concern
title: API v1 authenticable
description: Before-action that requires the ENV API token, accepted as a token parameter or a Bearer header.
tags: [api, security]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: authenticable
    title: Api::V1::Authenticable
    resource: ../../app/controllers/concerns/api/v1/authenticable.rb
---

# Behavior

- Included in the [V1 profiles controller](v1-profiles-controller.md) and the [V1 posts controller](v1-posts-controller.md), which registers `before_action :authenticate_api_token!`.[^authenticable]
- The token is read from `params[:token]` first, then from the `Authorization` header with `Bearer ` removed.[^authenticable]
- The comparison uses `ActiveSupport::SecurityUtils.secure_compare` against `ENV['API_TOKEN']`. A blank server token rejects every request.[^authenticable]
- A missing or invalid token returns 401.[^authenticable]

# Security note

Accepting `params[:token]` lets a token appear in the query string. Query strings are commonly written to proxy and application logs, so the Bearer header is the safer channel. This is the only accepted path, so changing it means updating `docs/API_AUTHENTICATION.md` in the repository.[^authenticable]
