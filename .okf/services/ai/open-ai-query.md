---
type: Service
title: OpenAI query
description: Sends one user message to an OpenAI chat model and returns the reply text.
tags: [text-analysis, services]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: open-ai-query
    title: AiServices::OpenAiQuery
    resource: ../../../app/services/ai_services/open_ai_query.rb
---

# Behavior

- Sends the text as a single user message to `gpt-3.5-turbo` at temperature 0.7 and returns the first choice's content through `handle_success`.[^open-ai-query]
- Called only by the profile classification rake task in `lib/tasks/ai/classify_profiles.rake`. It is not used by any controller or model.[^open-ai-query]

# Gotchas

- The client is created with `access_token: ''`, a literal empty string. Authentication depends on how the OpenAI client gem handles that value, so verify it before relying on this service.[^open-ai-query]
- There is no `rescue`. Provider errors propagate to the rake task instead of returning `handle_error`.[^open-ai-query]
