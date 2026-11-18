# TikTok services

Services in `TiktokServices` that fetch profiles and posts from tikAPI.io, transform the payloads, and classify errors.

- [Base](base.md) - Shared request, retry, parsing, and timestamp helpers
- [Get profile data](get-profile-data.md) - Calls `/public/check` by username
- [Get posts data](get-posts-data.md) - Calls `/public/posts` by secUid
- [Update profile data](update-profile-data.md) - Maps a raw `userInfo` payload to profile attributes
- [Update post data](update-post-data.md) - Maps one `itemList` entry to post attributes
- [Error classifier](error-classifier.md) - Classifies errors, defaulting to retry when unknown
