# Copilot Instructions for AI Agents

## Project Overview

This is a Ruby on Rails application for managing and analyzing influencer profiles, focused on Instagram and TikTok. The codebase is organized using standard Rails conventions, but includes custom service objects and admin modules for extended functionality.

## Architecture & Major Components

- **app/models/**: Core business logic, including:
  - Instagram: `Profile` (formerly `InstagramProfile`), `InstagramPost`
  - TikTok: `TiktokProfile`, `TiktokPost`
- **app/controllers/**: RESTful controllers for categories, profiles, posts, tags, and TikTok profiles. Admin controllers are in `app/admin/`.
- **app/services/**: Service objects for external integrations:
  - Instagram/Facebook: `InstagramServices`, `FacebookServices`
  - TikTok: `TiktokServices` (uses tikAPI.io)
- **app/views/**: ERB templates for user-facing and admin interfaces.
- **Active Storage**: Used for file uploads (avatars, images). Images are served via direct blob URLs (`/blob_files/...`) for better caching. If models are renamed, update `active_storage_attachments.record_type` accordingly.

## Developer Workflows

- **Start server**: `bin/rails server` or use `Procfile.dev` for multi-process dev setup.
- **Run tests**: `bin/rails test` (unit, integration, system tests in `test/`).
- **Database migrations**: `bin/rails db:migrate`. For model renames, also update related Active Storage records.
- **Docker**: `docker-compose.yml` for containerized development.

## Project-Specific Patterns

- **Model Renames**: When renaming models (e.g., `Profile` → `InstagramProfile`), update:
  - All references in code, views, and controllers
  - Active Storage attachments (`record_type` in DB)
  - Table names via migration (`rename_table :profiles, :instagram_profiles`)
- **Service Objects**: Located in `app/services/`, used for external API calls and data imports. Follow the pattern in `facebook_services/get_profile_data.rb`.
- **Admin Namespace**: Custom admin logic in `app/admin/`, separate from standard controllers.
- **Partial Rendering**: Pass explicit `as:` option when rendering collections to ensure correct local variable naming in partials.

## Integration Points

- **External APIs**:
  - Facebook and Instagram data import via service objects
  - TikTok data import via `TiktokServices` (tikAPI.io) - requires `TIKTOK_API_KEY` environment variable
- **Active Storage**: For file uploads; ensure correct model linkage after schema changes. Images are served via direct blob URLs (`/blob_files/:dir1/:dir2/:key`) through `BlobFilesController` for better caching and performance.
- **Docker**: Use for local development and testing.

## Instagram Integration

### Models

- **Profile** (`app/models/profile.rb`):

  - Stores Instagram user profile information (formerly `InstagramProfile`)
  - Fields: `username`, `uid`, `full_name`, `biography`, `followers`, `following`, `profile_pic_url`, `profile_pic_url_hd`, `is_private`, `is_verified`, `is_business_account`, `category_name`, `country_string`, `profile_type`, `data` (JSON)
  - Has many `instagram_posts`, `instagram_profile_stats`, `collaborated_collaborations`, `collaborator_collaborations`
  - Has one attached `avatar` (ActiveStorage)
  - Acts as taggable on `tags`
  - Scopes: `enabled`, `disabled`, `paraguayos`, `otros`, `micro`, `macro`, `tracked`, `marcas`, `medios`, `has_uid`, `has_profile_type`
  - Methods: `update_from_api_data`, `update_profile`, `update_profile_stats`, `save_avatar`, `estimated_reach`, `related_profiles`, `mentions_profiles`, `recent_posts`, `recent_collaborations`
  - After create callback: `update_profile`

- **InstagramPost** (`app/models/instagram_post.rb`):
  - Stores individual Instagram posts (images, videos, carousels)
  - Fields: `shortcode`, `url`, `caption`, `media`, `product_type`, `posted_at`, `likes_count`, `comments_count`, `video_view_count`, `total_count`, `data` (JSON)
  - Belongs to `profile`
  - Has one attached `image` (ActiveStorage)
  - Has many `instagram_collaborations`
  - Scopes: `a_day_ago`, `a_week_ago`, `a_month_ago`
  - Methods: `save_image`, `update_total_count`
  - Class methods: `word_occurrences`, `bigram_occurrences`

### Services

- **InstagramServices::Base** (`app/services/instagram_services/base.rb`):

  - Base class for all Instagram services, inherits from `ApplicationService`
  - Uses Scrape.do proxy to access Instagram API
  - Provides: `fetch_instagram_data`, `make_request`, `parse_response`, `with_retry`, `validate_username!`, `log_api_call`
  - Custom exceptions: `InvalidUsernameError`, `APIError`, `TimeoutError`, `ParseError`
  - Retry logic with exponential backoff (2s, 4s, 8s)
  - Uses `InstagramConfig` for API configuration

- **InstagramServices::GetProfileData** (`app/services/instagram_services/get_profile_data.rb`):

  - Fetches Instagram profile data by username
  - Endpoint: Instagram web profile API via Scrape.do proxy
  - Validates response structure and handles user not found errors
  - Returns raw API response data

- **InstagramServices::UpdateProfileData** (`app/services/instagram_services/update_profile_data.rb`):

  - Parses and transforms raw Instagram profile data
  - Extracts relevant fields: followers, following, profile pics, account type, categories, status flags, bio
  - Validates required fields and handles optional fields with defaults
  - Returns hash with profile attributes ready for database update

- **InstagramServices::GetPostsData** (`app/services/instagram_services/get_posts_data.rb`):

  - Fetches Instagram posts data for a profile
  - Retrieves both regular posts (`edge_owner_to_timeline_media`) and videos/reels (`edge_felix_video_timeline`)
  - Combines posts and videos into single array
  - Returns array of post edges

- **InstagramServices::UpdatePostData** (`app/services/instagram_services/update_post_data.rb`):

  - Parses and transforms raw Instagram post data
  - Extracts: shortcode, URL, caption, media type, timestamps, engagement metrics (likes, comments, views)
  - Handles cursor mode (different field for likes)
  - Returns hash with post attributes ready for database update

- **InstagramServices::ErrorClassifier** (`app/services/instagram_services/error_classifier.rb`):
  - Classifies API errors as permanent or temporary
  - Helps decide whether to disable profiles or retry

### Configuration

- **InstagramConfig** (`config/initializers/instagram_config.rb`):
  - API configuration loaded from environment variables
  - `SCRAPE_DO_TOKEN`: Required token for Scrape.do proxy service
  - `INSTAGRAM_APP_ID`: Instagram App ID (default: '936619743392459')
  - `INSTAGRAM_API_BASE_URL`: 'https://www.instagram.com/api/v1'
  - `SCRAPE_DO_API_URL`: 'http://api.scrape.do'
  - `INSTAGRAM_API_TIMEOUT`, `RATE_LIMIT_PER_MINUTE`, `MAX_RETRIES`, `RETRY_DELAY`, `LOG_API_CALLS`

### Data Access & Storage Flow

**Profile Data:**

1. `InstagramServices::GetProfileData.call(username)` → Fetches raw data from Instagram API
2. `InstagramServices::UpdateProfileData.call(raw_data)` → Transforms raw data to profile attributes
3. `profile.update!(attributes)` → Updates database fields
4. `profile.save_avatar` → Downloads and saves avatar image via ActiveStorage
5. Full API response stored in `profile.data` (JSON field)

**Post Data:**

1. `InstagramServices::GetPostsData.call(profile)` → Fetches posts and videos for profile
2. For each post edge:
   - `InstagramServices::UpdatePostData.call(edge)` → Transforms edge to post attributes
   - `post.find_or_create_by!(shortcode:)` → Finds or creates post record
   - `post.update!(attributes)` → Updates database fields
   - `post.save_image(display_url)` → Downloads and saves image via ActiveStorage
3. Full API response stored in `post.data` (JSON field)

### Rake Tasks

- **instagram:update_profiles** (`lib/tasks/instagram/update_profiles.rake`):

  - Updates all enabled Paraguayan Instagram profiles
  - Uses parallel processing (10 processes)
  - Calls `InstagramServices::GetProfileData` → `InstagramServices::UpdateProfileData` for each profile
  - Updates profile data and saves avatars automatically
  - Uses `ErrorClassifier` to handle permanent errors (disables profile) vs temporary errors
  - Shows summary with success/error/disabled counts

- **instagram:update_posts** (`lib/tasks/instagram/update_posts.rake`):

  - Updates posts for all tracked Instagram profiles
  - Uses parallel processing (10 processes)
  - Calls `InstagramServices::GetPostsData` for each profile
  - Processes each post: `InstagramServices::UpdatePostData` → saves post → saves image
  - Shows summary with posts updated counts

- **instagram:update_profile_posts** (`lib/tasks/instagram/update_profile_posts.rake`):

  - Updates posts for a specific profile (requires `PROFILE_ID` env var)
  - Interactive: warns if profile is disabled
  - Processes posts one by one with progress output

- **instagram:update_profiles_stats** (`lib/tasks/instagram/update_profiles_stats.rake`):

  - Updates aggregated statistics for profiles (likes, comments, engagement rate, etc.)

- **instagram:create_daily_stats** (`lib/tasks/instagram/create_daily_stats.rake`):

  - Creates daily statistics records for profiles

- **instagram:check_profile** (`lib/tasks/instagram/check_profile.rake`):

  - Checks if a profile exists and is accessible

- **instagram:update_news_posts** (`lib/tasks/instagram/update_news_posts.rake`):

  - Updates posts for news/media profiles

- **instagram:update_post_marcas** (`lib/tasks/instagram/update_post_marcas.rake`):
  - Updates posts for brand profiles

### Image Storage

- **Local Image Storage**: Instagram avatars and post images are saved locally using ActiveStorage
  - Avatars: `Profile#save_avatar` downloads from `profile_pic_url_hd` or `profile_pic_url`
  - Post Images: `InstagramPost#save_image` downloads from `display_url`
  - Both methods check if already attached before downloading
  - Images are served via direct blob URLs (`/blob_files/...`) for better caching
  - Helper: `StorageHelper#direct_blob_url` generates URLs in format `/blob_files/{key[0..1]}/{key[2..3]}/{key}`

## TikTok Integration

### Models

- **TiktokProfile** (`app/models/tiktok_profile.rb`):

  - Stores TikTok user profile information
  - Fields: `username`, `unique_id`, `nickname`, `followers`, `hearts`, `verified`, `avatar_larger`, `country_string`, `profile_type`, `data` (JSON)
  - Has many `tiktok_posts`
  - Has one attached `avatar` (ActiveStorage)
  - Scopes: `enabled`, `disabled`, `paraguayos`, `otros`, `micro`, `macro`, `tracked`, `marcas`, `medios`
  - Methods: `update_from_api_data`, `update_profile`, `update_posts`, `save_avatar`
  - Custom `data=` setter handles JSON strings from forms

- **TiktokPost** (`app/models/tiktok_post.rb`):
  - Stores individual TikTok video posts
  - Fields: `tiktok_post_id`, `desc`, `posted_at`, `likes_count`, `comments_count`, `play_count`, `shares_count`, `collects_count`, `total_count`, `cover_url`, `video_url`, `music_title`, `data` (JSON)
  - Belongs to `tiktok_profile`
  - Has one attached `cover` (ActiveStorage)
  - Scopes: `a_day_ago`, `a_week_ago`, `a_month_ago`
  - Methods: `update_from_api_data`, `save_cover`

### Services

- **TiktokServices::Base** (`app/services/tiktok_services/base.rb`):

  - Base class for all TikTok services, inherits from `ApplicationService`
  - Provides: `make_request`, `parse_response`, `with_retry`, `log_api_call`
  - Custom exceptions: `InvalidUsernameError`, `APIError`, `TimeoutError`, `ParseError`
  - Uses `TikTokConfig` for API configuration

- **TiktokServices::GetProfileData** (`app/services/tiktok_services/get_profile_data.rb`):

  - Fetches TikTok profile data by username
  - Endpoint: `/public/check`
  - Returns profile information including `secUid` needed for posts

- **TiktokServices::GetPostsData** (`app/services/tiktok_services/get_posts_data.rb`):
  - Fetches TikTok feed posts for a user
  - Endpoint: `/public/posts`
  - Accepts `secUid` (can resolve from `TiktokProfile` or username)
  - Defaults to 30 posts per page
  - Returns `itemList` array with post data

### Configuration

- **TikTokConfig** (`config/initializers/tiktok_config.rb`):
  - API configuration loaded from environment variables
  - `TIKTOK_API_KEY`: Required API key for tikAPI.io
  - `API_BASE_URL`, `API_TIMEOUT`, `MAX_RETRIES`, `RETRY_DELAY`, `LOG_API_CALLS`

### Controllers

- **TiktokProfilesController** (`app/controllers/tiktok_profiles_controller.rb`):

  - Public-facing controller for TikTok profiles
  - Routes: `GET /tiktok_profiles` (index), `GET /tiktok_profiles/:id` (show)
  - Includes: `ActiveStorage::SetCurrent`, `StorageHelper`, `SeoConcern`
  - Calculates metrics: total posts, interactions, play count, estimated reach
  - Uses conditional GETs for caching (`fresh_when`)

- **BlobFilesController** (`app/controllers/blob_files_controller.rb`):
  - Serves ActiveStorage blobs directly from filesystem
  - Route: `GET /blob_files/:dir1/:dir2/:key`
  - Mimics nginx/apache behavior for better caching
  - Sets appropriate cache headers (`Cache-Control: public, max-age=31536000`)
  - Gets content type from ActiveStorage blob record or file extension

### Views

- **Tiktok Profiles** (`app/views/tiktok_profiles/`):

  - `index.html.erb`: Grid listing of TikTok profiles
  - `show.html.erb`: Detailed profile view with metrics, charts, and posts
  - `_tiktok_profile.html.erb`: Profile card partial (similar to Instagram)
  - Uses `direct_blob_url` helper for avatar images with fallback to `avatar_larger`

- **Tiktok Posts** (`app/views/tiktok_post/_post.html.erb`):
  - Post card partial displaying video cover, stats, and engagement metrics
  - Uses `direct_blob_url` helper for cover images with fallback to `cover_url`
  - Shows: likes, comments, views, shares, engagement rate

### Active Admin

- **TiktokProfiles** (`app/admin/tiktok_profiles.rb`):

  - Admin interface for managing TikTok profiles
  - Menu: `parent: 'Profiles'`
  - Filters: username, country, profile_type, enabled, followers, etc.
  - Scopes: all, paraguayos, otros, enabled, disabled, micro, macro
  - Batch actions: `update_profile`, `update_posts`
  - Member actions: `update_profile`, `update_posts`
  - Custom index and show pages

- **TiktokPosts** (`app/admin/tiktok_posts.rb`):
  - Admin interface for managing TikTok posts
  - Menu: `parent: 'Posts', label: 'TikTok Posts'`
  - Filters: post_id, profile, description, stats, dates
  - Scopes: a_day_ago, a_week_ago, a_month_ago
  - Custom index and show pages

### Rake Tasks

- **tiktok:update_profiles** (`lib/tasks/tiktok/update_profiles.rake`):

  - Updates all enabled Paraguayan TikTok profiles
  - Uses parallel processing (10 processes)
  - Calls `TiktokServices::GetProfileData` for each profile
  - Updates profile data and saves avatars automatically
  - Shows summary with success/error counts

- **tiktok:update_posts** (`lib/tasks/tiktok/update_posts.rake`):
  - Updates posts for all tracked TikTok profiles
  - Uses parallel processing (10 processes)
  - Calls `TiktokServices::GetPostsData` for each profile
  - Saves posts and covers automatically
  - Shows summary with posts updated/created counts

### Image Storage

- **Local Image Storage**: TikTok avatars and post covers are saved locally using ActiveStorage
  - Avatars: `TiktokProfile#save_avatar` downloads from `avatar_larger` URL
  - Covers: `TiktokPost#save_cover` downloads from `cover_url`
  - Both methods check if already attached before downloading
  - Images are served via direct blob URLs (`/blob_files/...`) for better caching
  - Helper: `StorageHelper#direct_blob_url` generates URLs in format `/blob_files/{key[0..1]}/{key[2..3]}/{key}`

### Data Access & Storage Flow

**Profile Data:**

1. `TiktokServices::GetProfileData.call(username: 'username')` → Fetches profile data from tikAPI.io `/public/check` endpoint
2. `profile.update_from_api_data(api_data)` → Extracts and populates database fields from API response
3. `profile.save_avatar` → Downloads and saves avatar image via ActiveStorage (called automatically in `update_from_api_data`)
4. Full API response stored in `profile.data` (JSON field)

**Post Data:**

1. `TiktokServices::GetPostsData.call(sec_uid: sec_uid)` or `.call(username: 'username')` → Fetches posts from tikAPI.io `/public/posts` endpoint
2. For each post in `itemList`:
   - `post.find_or_create_by!(tiktok_post_id:)` → Finds or creates post record
   - `post.update_from_api_data(post_data)` → Extracts and populates database fields
   - `post.save_cover` → Downloads and saves cover image via ActiveStorage (called automatically in `update_from_api_data`)
3. Full API response stored in `post.data` (JSON field)

### Routes

- `GET /tiktok_profiles` - List all TikTok profiles
- `GET /tiktok_profiles/:id` - Show TikTok profile details
- `GET /blob_files/:dir1/:dir2/:key` - Serve ActiveStorage blobs directly (shared with Instagram)

## Examples

- To render a collection of profiles in a view:

  ```erb
  <%= render partial: "profiles/profile", collection: @instagram_profiles, as: :profile %>
  <%= render partial: "tiktok_profiles/tiktok_profile", collection: @tiktok_profiles, as: :tiktok_profile %>
  ```

- To update Active Storage after a model rename:

  ```ruby
  # Migration example
  execute "UPDATE active_storage_attachments SET record_type = 'InstagramProfile' WHERE record_type = 'Profile'"
  ```

- To use Instagram services:

  ```ruby
  # Get profile data (two-step process)
  result = InstagramServices::GetProfileData.call('username')
  if result.success?
    update_result = InstagramServices::UpdateProfileData.call(result.data)
    if update_result.success?
      profile.update!(update_result.data)
      profile.save_avatar
    end
  end

  # Get posts data
  result = InstagramServices::GetPostsData.call(profile)
  if result.success?
    result.data.each do |edge|
      post_result = InstagramServices::UpdatePostData.call(edge, cursor: true)
      if post_result.success?
        post = profile.instagram_posts.find_or_create_by!(shortcode: edge['node']['shortcode'])
        post.update!(post_result.data)
        post.save_image(edge['node']['display_url'])
      end
    end
  end
  ```

- To use TikTok services:

  ```ruby
  # Get profile data (single-step process)
  result = TiktokServices::GetProfileData.call(username: 'username')
  if result.success?
    profile.update_from_api_data(result.data) # Automatically saves avatar
  end

  # Get posts data
  result = TiktokServices::GetPostsData.call(sec_uid: profile.sec_uid)
  # or
  result = TiktokServices::GetPostsData.call(username: 'username')
  if result.success?
    result.data['itemList'].each do |post_data|
      post = profile.tiktok_posts.find_or_create_by!(tiktok_post_id: post_data['id'])
      post.update_from_api_data(post_data) # Automatically saves cover
    end
  end
  ```

- To use direct blob URLs for images:

  ```erb
  <% if profile.avatar.attached? %>
    <%= image_tag(direct_blob_url(profile.avatar), alt: profile.username) %>
  <% elsif profile.avatar_larger.present? %>
    <%= image_tag(profile.avatar_larger, alt: profile.username) %>
  <% end %>
  ```

- To run Instagram rake tasks:

  ```bash
  # Update all Instagram profiles
  rake instagram:update_profiles

  # Update posts for tracked profiles
  rake instagram:update_posts

  # Update posts for specific profile
  PROFILE_ID=123 rake instagram:update_profile_posts

  # Update profile statistics
  rake instagram:update_profiles_stats

  # Create daily statistics
  rake instagram:create_daily_stats
  ```

- To run TikTok rake tasks:

  ```bash
  # Update all TikTok profiles
  rake tiktok:update_profiles

  # Update posts for tracked profiles
  rake tiktok:update_posts
  ```

## Key Files & Directories

### Instagram

- `app/models/profile.rb` (formerly `instagram_profile.rb`)
- `app/controllers/profiles_controller.rb`
- `app/services/instagram_services/`, `app/services/facebook_services/`

### TikTok

- `app/models/tiktok_profile.rb`, `app/models/tiktok_post.rb`
- `app/controllers/tiktok_profiles_controller.rb`, `app/controllers/blob_files_controller.rb`
- `app/services/tiktok_services/base.rb`, `app/services/tiktok_services/get_profile_data.rb`, `app/services/tiktok_services/get_posts_data.rb`
- `app/admin/tiktok_profiles.rb`, `app/admin/tiktok_posts.rb`
- `app/views/tiktok_profiles/`, `app/views/tiktok_post/`
- `lib/tasks/tiktok/update_profiles.rake`, `lib/tasks/tiktok/update_posts.rake`
- `config/initializers/tiktok_config.rb`
- `app/helpers/storage_helper.rb` (direct blob URL helper)

### General

- `db/migrate/` (for schema changes)
- `Procfile.dev`, `docker-compose.yml` (for dev setup)

---

If any conventions or workflows are unclear, please ask for clarification or examples from the codebase.
