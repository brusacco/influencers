---
type: Controller
title: Errors controller
description: Renders the not-found, unprocessable, and internal-server error responses in HTML and JSON.
tags: [errors, public-site]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: errors-controller
    title: ErrorsController
    resource: ../../app/controllers/errors_controller.rb
---

# Actions

`not_found` (404), `unprocessable_entity` (422), and `internal_server_error` (500) each respond to HTML and JSON. The shared handlers in the [application controller](application-controller.md) render the same error templates.[^errors-controller]
