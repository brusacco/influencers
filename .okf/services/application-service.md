---
type: Service
title: Application service
description: Base class for service objects that return a success or error result object.
tags: [services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: application-service
    title: ApplicationService
    resource: ../../app/services/application_service.rb
---

# Contract

- `ApplicationService.call(...)` instantiates the service and calls `call` on it.[^application-service]
- `handle_success(data)` returns an `OpenStruct` with `success?: true` and `data`.[^application-service]
- `handle_error(error)` returns an `OpenStruct` with `success?: false` and `error`.[^application-service]

Callers check `result.success?` before reading `data` or `error`. The contract has no exceptions, so each subclass must rescue its own failures.[^application-service]
