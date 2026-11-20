# API v1

- [V1 profiles controller](v1-profiles-controller.md) - Public profile search and token-protected profile lookup
- [V1 posts controller](v1-posts-controller.md) - Token-protected Instagram post endpoints:
  - `GET /api/v1/posts` - recent posts from the last 24 hours, optionally filtered by `profile_type`
  - `GET /api/v1/posts/search` - caption search across posts, with limit and `profile_type` filters
  - `GET /api/v1/profiles/:username/posts` - the latest 100 posts for one profile
- [Authenticable](authenticable.md) - Bearer or query-string API token check shared by the API controllers

The public contract is documented in `docs/API_DOCUMENTATION.md` and `docs/API_AUTHENTICATION.md` in the repository.
