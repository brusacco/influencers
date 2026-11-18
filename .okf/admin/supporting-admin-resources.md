---
type: Admin Resource
title: Supporting admin resources
description: Active Admin resources for Instagram posts, TikTok posts, tags, and admin users.
tags: [admin, auth]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T14:00:00Z
sources:
  - id: instagram-posts-admin
    title: Instagram posts admin resource
    resource: ../../app/admin/instagram_posts.rb
  - id: tiktok-posts-admin
    title: TikTok posts admin resource
    resource: ../../app/admin/tiktok_posts.rb
  - id: tag-admin
    title: Tag admin resource
    resource: ../../app/admin/tag.rb
  - id: admin-users-admin
    title: Admin users resource
    resource: ../../app/admin/admin_users.rb
---

# Instagram posts

Filters only by shortcode. The index shows caption, timestamps, counts, product type, and media.[^instagram-posts-admin]

# TikTok posts

Filters by provider post id, profile, description, timestamps, and engagement counts. Scopes cover all posts (default), a day, a week, and a month.[^tiktok-posts-admin]

# Tags

Permits only `name`. Tags categorize Instagram profiles. See the [tag model](/shared/tag.md).[^tag-admin]

# Admin users

Lists email, sign-in activity, and creation time. The form takes email, password, and confirmation. Accounts are the only authentication records. See the [admin user model](/shared/admin-user.md).[^admin-users-admin]
