# Instagram services

Services in `InstagramServices` that fetch profiles and posts from the Scrape.do proxy, transform the payloads, and classify errors.

- [Base](base.md) - Shared request, retry, validation, and error types
- [Get profile data](get-profile-data.md) - Fetches the web profile payload for a username
- [Get posts data](get-posts-data.md) - Fetches posts and reels from the same payload
- [Ferrum posts fetcher](ferrum-posts-fetcher.md) - Uses a direct Chrome session to collect public post metadata
- [Ferrum post upserter](ferrum-post-upserter.md) - Persists available browser-collected metadata without erasing existing fields
- [Scrape.do GraphQL posts fetcher](scrape-do-graphql-posts-fetcher.md) - Experimental API-only profile-grid collector with no local browser traffic
- [Scrape.do GraphQL post upserter](scrape-do-graphql-post-upserter.md) - Safely persists one API-only profile-grid node
- [Scrape.do GraphQL profile fetcher](scrape-do-graphql-profile-fetcher.md) - Retrieves the public profile root through the API-only flow
- [Scrape.do GraphQL profile upserter](scrape-do-graphql-profile-upserter.md) - Safely applies fields exposed by that root query
- [Update profile data](update-profile-data.md) - Maps a raw payload to profile attributes
- [Update post data](update-post-data.md) - Maps a post edge to post attributes
- [Get related profiles](get-related-profiles.md) - Extracts related usernames
- [Error classifier](error-classifier.md) - Decides whether a failure disables a profile
