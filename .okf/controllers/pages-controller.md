---
type: Controller
title: Pages controller
description: Serves the static about page and sets its Open Graph and Twitter meta tags.
tags: [public-site, seo]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: pages-controller
    title: PagesController
    resource: ../../app/controllers/pages_controller.rb
---

# Action

`about` (`GET /acerca-de`) renders the static about page. It sets its meta tags through the [SEO concern](seo-concern.md), which uses the shared Open Graph image and Twitter handle constants.[^pages-controller]
