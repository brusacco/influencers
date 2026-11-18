---
type: Controller
title: Home controller
description: Serves the homepage and the POST /deploy endpoint, which runs production deployment commands.
tags: [public-site, security, operations]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: home-controller
    title: HomeController
    resource: ../../app/controllers/home_controller.rb
---

# Actions

- `index` (`GET /`) sets the homepage meta tags through the [SEO concern](seo-concern.md).[^home-controller]
- `deploy` (`POST /deploy`) changes into the production application directory and runs `git checkout`, `git pull`, `bundle install`, `db:migrate`, `assets:precompile`, and `whenever -i`. The Puma restart is commented out, so the app is not restarted by this action.[^home-controller]

# Security gotcha

`HomeController` skips `verify_authenticity_token`, and `deploy` performs no token or credential check of its own. Anyone who can reach `POST /deploy` can trigger a deployment, so the endpoint is an operational risk. AGENTS.md treats deploy as operationally sensitive. Any change should add authentication before the route is exposed.[^home-controller]
