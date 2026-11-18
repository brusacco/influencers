# Services

Service objects that talk to external providers and transform their payloads. Each service returns an `OpenStruct` with `success?` and either `data` or `error`, produced by [ApplicationService](application-service.md).

- [Instagram services](instagram/index.md) - Scrape.do-backed profile and post fetching, transformation, and error classification
- [TikTok services](tiktok/index.md) - tikAPI.io-backed profile and post fetching, transformation, and error classification
- [Facebook services](facebook/get-profile-data.md) - Graph API profile fetch with no callers
- [OpenAI query](ai/open-ai-query.md) - Chat completion wrapper used only by a rake task

Keep external API behavior in these namespaces rather than in controllers or models, per AGENTS.md.
