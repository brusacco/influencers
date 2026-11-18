---
type: Service
title: Facebook get profile data
description: Fetches a Facebook page profile from the Graph API. Has no callers in the application.
tags: [services, security, legacy]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: facebook-get-profile-data
    title: FacebookServices::GetProfileData
    resource: ../../../app/services/facebook_services/get_profile_data.rb
---

# Behavior

- Calls the Graph API `v8.0` for a page uid with a fixed field list and maps the response to name, username, followers, category, description, website, and picture.[^facebook-get-profile-data]
- Returns the result through `handle_success`.[^facebook-get-profile-data]

# Gotchas

- The access token is hardcoded in the source. Do not copy it into docs, logs, or tests. The credential should move to an environment variable or credentials, and the token should be rotated.[^facebook-get-profile-data]
- There is no timeout, no retry, and no `rescue`. Network failures and invalid JSON propagate to the caller instead of returning `handle_error`.[^facebook-get-profile-data]
- No code calls this service, as confirmed by a repository search. Treat it as dead code until a caller is added, and check the [services index](../index.md) before reusing it.[^facebook-get-profile-data]
