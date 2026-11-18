# Influencers Paraguay

Rails application for tracking public Instagram and TikTok profiles in Paraguay.

## Requirements

- Ruby 3.3.0
- MySQL
- A `SCRAPE_DO_TOKEN` environment variable for Instagram collection

Install dependencies and prepare the database:

```bash
bundle install
bin/rails db:prepare
```

Run the application locally with:

```bash
bin/dev
```

## Instagram collection

Instagram collection uses Scrape.do's API and Instagram's public GraphQL
queries. The application host does not make the profile-grid requests directly
to Instagram.

Use `bundle exec rake` in development. In production, prepend
`RAILS_ENV=production` (or use the environment configured by the process
manager).

### Scheduled tasks

| Task | Schedule | Profiles selected |
| --- | --- | --- |
| `instagram:update_news_posts` | Every 4 hours | Enabled Paraguayan profiles with `profile_type: medio` |
| `instagram:update_posts` | Every 8 hours | Enabled Paraguayan profiles with 10,000+ followers, excluding `medio` |
| `instagram:update_profiles` | Every 24 hours | Enabled Paraguayan profiles |

`instagram:update_posts` intentionally excludes news/media accounts. They are
updated only by `instagram:update_news_posts`, avoiding duplicate crawls.

### Refresh profiles and avatars

```bash
bundle exec rake instagram:update_profiles
```

Refreshes follower metrics, public profile data, and the avatar. Avatar files
are saved only when Instagram returns a valid image; expired CDN error messages
are not stored as profile images.

Bounded production check:

```bash
INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT=5 bundle exec rake instagram:update_profiles
```

### Refresh general post grids

```bash
bundle exec rake instagram:update_posts
```

Refreshes posts for the general tracked-profile set, ordered from most to fewest
followers. It excludes `medio` accounts.

To also inspect inactive non-media profiles, use:

```bash
CHECK_INACTIVE=1 bundle exec rake instagram:update_posts
```

Inactive profiles are enabled while being checked. If Instagram does not expose
their public post-grid GraphQL query, they are disabled again. Transient fetch
errors do not change the profile state.

### Refresh news post grids

```bash
bundle exec rake instagram:update_news_posts
```

Refreshes posts for enabled Paraguayan accounts whose `profile_type` is
`medio`. The direct technical entry point is also available as:

```bash
bundle exec rake instagram:update_news_posts_scrape_do_graphql
```

It accepts the same inactive-profile verification behavior:

```bash
CHECK_INACTIVE=1 bundle exec rake instagram:update_news_posts
```

### Common options

All three scheduled tasks accept these options where applicable:

| Variable | Default | Applies to | Description |
| --- | --- | --- | --- |
| `INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT` | no limit | all three | Processes only the highest-follower N selected profiles. The value must be positive. |
| `INSTAGRAM_SCRAPE_DO_CONCURRENCY` | `5` | all three | Number of worker threads, from `1` to `10`. Set it to `1` for sequential execution. |
| `CHECK_INACTIVE` | unset | post tasks only | Set to `1` to include inactive profiles in the verification flow. |
| `INSTAGRAM_FERRUM_PAUSE_SECONDS` | `2` | all three | Pause after each successfully updated profile per worker. |

Examples:

```bash
# Safe smoke test: five profiles, sequentially
INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT=5 INSTAGRAM_SCRAPE_DO_CONCURRENCY=1 \
  bundle exec rake instagram:update_posts

# Explicitly process up to five profiles at once
INSTAGRAM_SCRAPE_DO_CONCURRENCY=5 \
  bundle exec rake instagram:update_profiles

# Test inactive media profiles in a small batch
CHECK_INACTIVE=1 INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT=5 \
  bundle exec rake instagram:update_news_posts
```

The application defaults to five workers for each Scrape.do task. Set a lower
value for a conservative smoke test or when investigating provider errors.
Each task also takes a non-blocking lock; if an earlier run of the same rake is
still active, the later invocation exits without sending duplicate requests.
When either post collector finds a post without `posted_at`, it automatically
uses the public detail query to store its exact publication time. Posts that
already have a date skip that extra request and only refresh grid data.

### Single-profile and diagnostic tasks

These tasks are manual and are not scheduled:

```bash
# Inspect the GraphQL post grid without writes
bundle exec rake 'instagram:probe_posts_scrape_do_graphql[username]'

# Fetch and persist one profile's post grid
bundle exec rake 'instagram:import_posts_scrape_do_graphql[username]'

# Production-facing alias for the same one-profile update flow
bundle exec rake 'instagram:update_posts_scrape_do_graphql[username]'
```

The legacy direct-browser fallback remains available as
`instagram:update_posts_ferrum`; it is for diagnostics only and is not part of
the scheduled Scrape.do collection path.

### Backfill missing publication dates

The profile grid does not include an exact publication timestamp. To populate
only posts whose `posted_at` is empty, the detail query can be run manually:

```bash
bundle exec rake instagram:update_missing_posted_at
```

It makes one additional Scrape.do page request and one GraphQL detail request
per post. Start with a bounded batch:

```bash
INSTAGRAM_SCRAPE_DO_POST_LIMIT=10 \
  INSTAGRAM_SCRAPE_DO_CONCURRENCY=5 \
  bundle exec rake instagram:update_missing_posted_at
```

The task is not scheduled. It processes only `posted_at IS NULL`, prioritizes
the newest records by descending ID, and caps every execution at 1,000 posts.
Use `INSTAGRAM_SCRAPE_DO_POST_LIMIT` to choose a smaller batch. It also uses
its own non-blocking lock to avoid duplicate backfill runs.

## Verification

Run the relevant test file before broader validation:

```bash
bin/rails test
```

For a production smoke test, always begin with
`INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT` before running a complete collection.
