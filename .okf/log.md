# Update Log

## 2026-11-18

- **Change**: Public Instagram post cards no longer display comment counts; their per-card rate is now based on visible likes because the current GraphQL grid does not provide reliable comments.
- **Change**: Public Instagram post cards now render posts that lack an attached image, using the retained GraphQL image URL or a placeholder as a final fallback.
- **Change**: Public Instagram profile metrics and charts now use the last 15 days of posts. The “Posteos Recientes” gallery continues to show the latest `RECENT_POSTS_LIMIT` posts regardless of publication date.
- **Addition**: Added the experimental [Scrape.do GraphQL posts fetcher](services/instagram/scrape-do-graphql-posts-fetcher.md) and non-persisting probe rake. It retrieves the profile grid via Scrape.do API GET plus POST, keeping both calls off the application host's direct Instagram IP.
- **Addition**: Added the manual Scrape.do GraphQL import path and [post upserter](services/instagram/scrape-do-graphql-post-upserter.md). The first import for `bancofamiliar` processed 12 grid posts: 8 were new and 4 were updated without overwriting unavailable grid fields.
- **Addition**: Added `instagram:update_posts_scrape_do_graphql[username]`, an explicit-profile alias suitable for a controlled production test of the Scrape.do GraphQL import path.
- **Addition**: Added `instagram:update_news_posts_scrape_do_graphql`, an unscheduled Paraguayan `medio` batch updater with an optional bounded-run limit for production validation.
- **Change**: The Scrape.do news updater now includes disabled Paraguayan `medio` profiles and enables each one as it begins processing, to recover media accounts disabled by the legacy rake.
- **Change**: `instagram:update_posts` now delegates to the working direct-browser GraphQL collector because the prior Scrape.do call to Instagram's retired profile endpoint returns 404 for valid profiles. The collector has a bounded smoke-test option through `INSTAGRAM_FERRUM_PROFILE_LIMIT`.

## 2026-11-10

- **Change**: The manual [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) now retrieves the visible post batch through the profile's internal GraphQL query, avoiding individual navigation to every post.
- **Change**: The manual [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) now supports a direct default and an opt-in Scrape.do Proxy Mode, making the two responses comparable without changing tasks.
- **Change**: The manual [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) now connects directly to Instagram, without Scrape.do, because proxy responses were login-limited and omitted public post data.
- **Addition**: Added the [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) and [Ferrum post upserter](services/instagram/ferrum-post-upserter.md), plus an unscheduled `instagram:update_posts_ferrum` fallback. It refuses empty login-limited profile views rather than treating them as fresh data.
- **Creation**: Business-logic area ([profile qualification](business/profile-qualification.md), [auto-disable policy](business/auto-disable-policy.md), [ingestion schedule](business/ingestion-schedule.md), [collaboration detection](business/collaboration-detection.md)) and the [Active Admin area](admin/index.md). Recorded rules: permanent provider errors disable a profile while temporary ones do not, and the 10,000, 40,000, and 50,000 follower floors serve different purposes.
- **Creation**: Bundle documenting all ActiveRecord models and their concerns - [Profile](instagram/profile.md), [Instagram post](instagram/post.md), [Instagram profile stat](instagram/profile-stat.md), [Instagram collaboration](instagram/collaboration.md), [TikTok profile](tiktok/profile.md), [TikTok post](tiktok/post.md), [Tag](shared/tag.md), [Admin user](shared/admin-user.md), [JSON data setter](shared/json-data-setter.md), [Image downloader](shared/image-downloader.md), [Reach calculator](shared/reach-calculator.md).
- **Creation**: Bundle documenting public controllers ([Application controller](controllers/application-controller.md), [Instagram profiles controller](controllers/instagram-profiles-controller.md), [Posts controller](controllers/posts-controller.md), [Home controller](controllers/home-controller.md)), the [API v1 controllers](api/index.md), and the [service objects](services/index.md). Recorded gotchas: the unauthenticated `POST /deploy` endpoint, the TikTok retry wrapper that never retries network errors, and the hardcoded Facebook token that must not be copied.
