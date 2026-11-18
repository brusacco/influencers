---
type: Concern
title: SEO concern
description: Shared meta-tag helpers for page controllers, covering title, description, canonical, Open Graph, and Twitter cards.
tags: [seo, public-site]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: seo-concern
    title: SeoConcern
    resource: ../../app/controllers/concerns/seo_concern.rb
---

# Overview

`SeoConcern` is mixed into the [home](home-controller.md), [category](category-controller.md), [tags](tags-controller.md), [pages](pages-controller.md), and profile controllers. Each helper sets the title, description, keywords, canonical URL, Open Graph tags, and Twitter card tags for one page type.[^seo-concern]

# Helpers

- `set_homepage_meta_tags` and `set_profiles_index_meta_tags`.
- `set_profile_meta_tags(profile)` for profile detail pages. It builds the canonical and `og:url` from the profile URL.
- `set_tag_meta_tags` and `set_category_meta_tags`, which include the result count.
- `set_about_meta_tags`.[^seo-concern]

Site-wide values come from constants such as `SITE_NAME`, `SITE_TAGLINE`, `DESCRIPTION`, `KEYWORDS`, `OG_IMAGE_URL`, and `TWITTER_HANDLE`.[^seo-concern]
