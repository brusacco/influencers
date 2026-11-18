---
type: Configuration
title: Active Admin configuration
description: Global Active Admin settings for title, pagination, authentication, the current user, and logout.
tags: [admin, auth]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: active-admin-initializer
    title: Active Admin initializer
    resource: ../../config/initializers/active_admin.rb
  - id: admin-dashboard
    title: Admin dashboard page
    resource: ../../app/admin/dashboard.rb
---

# Settings

- Site title is `Influencers`, with 100 rows per page by default.[^active-admin-initializer]
- Batch actions are enabled.[^active-admin-initializer]
- Authentication calls `authenticate_admin_user!`, and the current user is returned by `current_admin_user`. Both come from the [admin user](/shared/admin-user.md) Devise model.[^active-admin-initializer]
- Logout uses `destroy_admin_user_session_path`.[^active-admin-initializer]
- Attributes `encrypted_password`, `password`, and `password_confirmation` are filtered from displays and exports.[^active-admin-initializer]
- Dates use the `:long` localize format.[^active-admin-initializer]

# Dashboard

The dashboard shows only a welcome message. The sample panels are commented out.[^admin-dashboard]

# Notes

No CanCan or Pundit authorization adapter is enabled. Any admin account has full access to every registered resource.[^active-admin-initializer]
