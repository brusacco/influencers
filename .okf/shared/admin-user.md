---
type: Model
title: Admin user model
description: Devise account for the administration interface, the only application authentication model.
tags: [auth]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: admin-user-model
    title: AdminUser model
    resource: ../../app/models/admin_user.rb
  - id: admin-users-schema
    title: admin_users table schema
    resource: ../../db/schema.rb
---

# Overview

`AdminUser` is the only authentication model in the application. It backs the Active Admin interface.[^admin-user-model]

# Modules

Devise provides `database_authenticatable`, `recoverable`, `rememberable`, and `validatable`.[^admin-user-model]

# Schema

`admin_users` stores `email` (unique), `encrypted_password`, reset-password fields, and `remember_created_at`.[^admin-users-schema]

# Notes

Public visitors have no accounts. Access to admin pages depends only on this model. Active Admin forms submit the `data` column as JSON strings, which the [JSON data setter](/shared/json-data-setter.md) normalizes.
