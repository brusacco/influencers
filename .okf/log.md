# Update Log

## 2026-11-18

- **Change**: Scrape.do profile and post batch rakes now accept `INSTAGRAM_SCRAPE_DO_CONCURRENCY` (1 through 10) and default to five workers. The recurring schedule now staggers all jobs to avoid top-of-hour collector collisions, and task-specific locks prevent duplicate overlapping runs.
- **Change**: Instagram news post collection now runs every four hours and general post collection every eight hours, preserving their staggered schedule.
- **Change**: `InstagramServices::GetProfileData` now adapts the Scrape.do public GraphQL profile response to its legacy `data.user` contract, removing its dependency on the retired web-profile endpoint.
- **Change**: `InstagramServices::GetPostsData` and its manual brand, tagged, and single-profile rakes now use the Scrape.do GraphQL post grid and upserter instead of the retired web-profile endpoint and edge payload.
- **Deprecation**: The retained `InstagramServices::Base#fetch_instagram_data` and `UpdatePostData` edge transformer no longer have active callers; new Instagram ingestion must use the dedicated Scrape.do GraphQL services.
- **Addition**: Added `instagram:update_missing_posted_at`, a manual Scrape.do GraphQL detail-query backfill that sets exact publication dates only for posts whose `posted_at` is null.
- **Change**: The scheduled Scrape.do post upserter now retrieves and stores an exact publication date for any fetched post whose `posted_at` is missing; posts with an existing date skip the detail query.
- **Change**: `instagram:update_posts` now excludes `medio` profiles, leaving their crawl exclusively to `instagram:update_news_posts`.
- **Fix**: Profile avatar downloads now prefer the freshly updated GraphQL URL and reject non-image and failed upstream responses, preventing expired URL error messages from being attached and publicly served as avatars.
- **Change**: `instagram:update_profiles` now refreshes enabled Paraguayan profiles through Scrape.do's public GraphQL profile-root query, preserving fields not returned by that query.
- **Change**: `instagram:update_news_posts` now delegates to the Scrape.do GraphQL media updater, preserving the scheduled rake name while replacing the retired profile endpoint.
- **Fix**: Scrape.do batch updaters now honor descending follower order. They previously used `find_each`, which ignores relation ordering and batches by primary key.
- **Change**: Instagram GraphQL imports now retain only compact post metadata instead of the full nested payload, preventing large carousel responses from exceeding the `instagram_posts.data` `TEXT` column limit.
- **Change**: Public Instagram post cards no longer display comment counts; their per-card rate is now based on visible likes because the current GraphQL grid does not provide reliable comments.
- **Change**: Public Instagram post cards now render posts that lack an attached image, using the retained GraphQL image URL or a placeholder as a final fallback.
- **Change**: Public Instagram profile metrics and charts now use the last 15 days of posts. The “Posteos Recientes” gallery continues to show the latest `RECENT_POSTS_LIMIT` posts regardless of publication date.
- **Addition**: Added the experimental [Scrape.do GraphQL posts fetcher](services/instagram/scrape-do-graphql-posts-fetcher.md) and non-persisting probe rake. It retrieves the profile grid via Scrape.do API GET plus POST, keeping both calls off the application host's direct Instagram IP.
- **Addition**: Added the manual Scrape.do GraphQL import path and [post upserter](services/instagram/scrape-do-graphql-post-upserter.md). The first import for `bancofamiliar` processed 12 grid posts: 8 were new and 4 were updated without overwriting unavailable grid fields.
- **Addition**: Added `instagram:update_posts_scrape_do_graphql[username]`, an explicit-profile alias suitable for a controlled production test of the Scrape.do GraphQL import path.
- **Addition**: Added `instagram:update_news_posts_scrape_do_graphql`, an unscheduled Paraguayan `medio` batch updater with an optional bounded-run limit for production validation.
- **Change**: The Scrape.do news updater now includes disabled Paraguayan `medio` profiles and enables each one as it begins processing, to recover media accounts disabled by the legacy rake.
- **Change**: The Scrape.do news updater disables a profile again when Instagram omits its public post-grid query; transient fetch failures do not change profile state.
- **Change**: Both Scrape.do batch updaters now process active profiles by default. `CHECK_INACTIVE=1` expands either task to verify inactive profiles and only retains reactivation when their public post grid is available.
- **Change**: `instagram:update_posts` now refreshes `Profile.tracked` through Scrape.do API GraphQL instead of the direct-browser fallback; its every-six-hours schedule is unchanged.
- **Change**: `instagram:update_posts` now delegates to the working direct-browser GraphQL collector because the prior Scrape.do call to Instagram's retired profile endpoint returns 404 for valid profiles. The collector has a bounded smoke-test option through `INSTAGRAM_FERRUM_PROFILE_LIMIT`.

## 2026-11-10

- **Change**: The manual [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) now retrieves the visible post batch through the profile's internal GraphQL query, avoiding individual navigation to every post.
- **Change**: The manual [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) now supports a direct default and an opt-in Scrape.do Proxy Mode, making the two responses comparable without changing tasks.
- **Change**: The manual [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) now connects directly to Instagram, without Scrape.do, because proxy responses were login-limited and omitted public post data.
- **Addition**: Added the [Ferrum post fetcher](services/instagram/ferrum-posts-fetcher.md) and [Ferrum post upserter](services/instagram/ferrum-post-upserter.md), plus an unscheduled `instagram:update_posts_ferrum` fallback. It refuses empty login-limited profile views rather than treating them as fresh data.
- **Creation**: Business-logic area ([profile qualification](business/profile-qualification.md), [auto-disable policy](business/auto-disable-policy.md), [ingestion schedule](business/ingestion-schedule.md), [collaboration detection](business/collaboration-detection.md)) and the [Active Admin area](admin/index.md). Recorded rules: permanent provider errors disable a profile while temporary ones do not, and the 10,000, 40,000, and 50,000 follower floors serve different purposes.
- **Creation**: Bundle documenting all ActiveRecord models and their concerns - [Profile](instagram/profile.md), [Instagram post](instagram/post.md), [Instagram profile stat](instagram/profile-stat.md), [Instagram collaboration](instagram/collaboration.md), [TikTok profile](tiktok/profile.md), [TikTok post](tiktok/post.md), [Tag](shared/tag.md), [Admin user](shared/admin-user.md), [JSON data setter](shared/json-data-setter.md), [Image downloader](shared/image-downloader.md), [Reach calculator](shared/reach-calculator.md).
- **Creation**: Bundle documenting public controllers ([Application controller](controllers/application-controller.md), [Instagram profiles controller](controllers/instagram-profiles-controller.md), [Posts controller](controllers/posts-controller.md), [Home controller](controllers/home-controller.md)), the [API v1 controllers](api/index.md), and the [service objects](services/index.md). Recorded gotchas: the unauthenticated `POST /deploy` endpoint, the TikTok retry wrapper that never retries network errors, and the hardcoded Facebook token that must not be copied.
