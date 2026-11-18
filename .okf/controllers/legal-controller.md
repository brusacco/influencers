---
type: Controller
title: Legal controller
description: Serves the privacy and terms pages, both indexable, with page-specific meta tags.
tags: [public-site, seo]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: legal-controller
    title: LegalController
    resource: ../../app/controllers/legal_controller.rb
---

# Actions

- `privacy` (`GET /privacidad`) and `terms` (`GET /terminos`) set their title, description, and `robots: index, follow` tags.[^legal-controller]
- Both use the site name constant.[^legal-controller]
