---
type: Controller
title: Application controller
description: Base controller that maps not-found, routing, and invalid-record errors to HTML or JSON error responses.
tags: [errors, public-site]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: application-controller
    title: ApplicationController
    resource: ../../app/controllers/application_controller.rb
---

# Overview

`ApplicationController` is the base class for the public HTML controllers. It sets `helper :storage` and declares the shared error handling for every subclass.[^application-controller]

# Error handling

- `ActiveRecord::RecordNotFound` and `ActionController::RoutingError` render the not-found response with status 404.[^application-controller]
- `ActiveRecord::RecordInvalid` and `ActionController::InvalidAuthenticityToken` render the unprocessable response with status 422.[^application-controller]
- Each handler branches on the request format. HTML renders the matching [error page](/controllers/errors-controller.md) inside the application layout. JSON returns `{ error: ... }`.[^application-controller]

# Notes

No authentication or caching is configured here. The [API controllers](/api/v1-profiles-controller.md) inherit from this class but add their own token check.
