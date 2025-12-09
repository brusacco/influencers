# Copilot Instructions for AI Agents

## Project Overview

This is a Ruby on Rails application for managing and analyzing influencer profiles, focused on Instagram and TikTok. The codebase is organized using standard Rails conventions, but includes custom service objects and admin modules for extended functionality.

## Architecture & Major Components

### Architecture Overview

The application follows a **layered MVC architecture** with a **Service Object pattern** for external integrations and complex business logic. The architecture emphasizes:

- **Separation of Concerns**: Business logic in models/concerns, API logic in services, presentation in controllers/views
- **Fat Models, Skinny Controllers**: Controllers delegate to models and services
- **Service Layer**: External API interactions and data transformations isolated in service objects
- **Concerns for Reusability**: Shared functionality extracted into concerns (`JsonDataSetter`, `ImageDownloader`, `ReachCalculator`)
- **Error Handling**: Centralized error classification and handling via `ErrorClassifier` services

### Layer Responsibilities

#### 1. **Models Layer** (`app/models/`)
- **Primary Responsibility**: Business logic, data persistence, validations, scopes
- **Pattern**: Fat models with concerns for shared functionality
- **Key Models**:
  - `Profile` (Instagram profiles) - includes `save_avatar`, `update_profile`, `estimated_reach`
  - `InstagramPost` - includes `save_image`, `update_total_count`
  - `TiktokProfile` - includes concerns: `JsonDataSetter`, `ImageDownloader`, `ReachCalculator`
  - `TiktokPost` - includes concerns: `JsonDataSetter`, `ImageDownloader`
- **Concerns** (`app/models/concerns/`):
  - `JsonDataSetter`: Handles JSON data field setters (Hash/String conversion)
  - `ImageDownloader`: Downloads and attaches images from URLs via ActiveStorage
  - `ReachCalculator`: Calculates estimated reach using hybrid follower/interaction method
- **Active Storage**: Models use `has_one_attached` for avatars/images

#### 2. **Service Layer** (`app/services/`)
- **Primary Responsibility**: External API interactions, data transformation, error handling
- **Base Pattern**: All services inherit from `ApplicationService` with standardized `call` method
- **Service Structure**:
  ```
  ApplicationService (base)
  ├── InstagramServices::Base
  │   ├── GetProfileData (fetch raw data)
  │   ├── UpdateProfileData (transform data)
  │   ├── GetPostsData (fetch raw data)
  │   ├── UpdatePostData (transform data)
  │   └── ErrorClassifier (classify errors)
  ├── TiktokServices::Base
  │   ├── GetProfileData (fetch raw data)
  │   ├── UpdateProfileData (transform data)
  │   ├── GetPostsData (fetch raw data)
  │   ├── UpdatePostData (transform data)
  │   └── ErrorClassifier (classify errors)
  └── FacebookServices
  ```
- **Service Pattern**: Two-step process for data updates:
  1. **Fetch Service** (`Get*Data`): Retrieves raw API response
  2. **Transform Service** (`Update*Data`): Transforms raw data to model attributes
- **Return Pattern**: Services return `OpenStruct` with `success?`, `data`, and `error` keys
- **Error Classification**: `ErrorClassifier` services categorize errors as permanent/temporary/unknown

#### 3. **Controllers Layer** (`app/controllers/`)
- **Primary Responsibility**: HTTP request handling, response formatting, view data preparation
- **Pattern**: Skinny controllers that delegate to models/services
- **Base Controller**: `ApplicationController` handles:
  - Exception handling (`RecordNotFound`, `RoutingError`, `RecordInvalid`)
  - Custom error pages (404, 422, 500)
  - Storage helper inclusion
- **Public Controllers**:
  - `ProfilesController`, `TiktokProfilesController`: Profile listing and detail pages
  - `PostsController`: Post listing and filtering
  - `TagsController`, `CategoryController`: Content organization
  - `BlobFilesController`: Direct ActiveStorage blob serving
- **API Controllers** (`app/controllers/api/v1/`):
  - `ProfilesController`: Profile search and retrieval API
  - `PostsController`: Post listing API
  - Authentication via `Api::V1::Authenticable` concern
- **Controller Concerns** (`app/controllers/concerns/`):
  - `SeoConcern`: SEO meta tags and structured data
  - `Api::V1::Authenticable`: API authentication

#### 4. **Views Layer** (`app/views/`)
- **Template Engine**: ERB (Embedded Ruby)
- **Layouts**: Application layout with navigation, footer, SEO meta tags
- **Partials**: Reusable components (`_profile.html.erb`, `_post.html.erb`, `_tiktok_profile.html.erb`)
- **Styling**: Tailwind CSS (via `application.tailwind.css`)
- **Image Handling**: Uses `direct_blob_url` helper with fallback to original URLs

#### 5. **Admin Layer** (`app/admin/`)
- **Framework**: ActiveAdmin
- **Authentication**: Devise for admin users
- **Admin Resources**:
  - `Profiles`, `InstagramPosts`: Instagram profile/post management
  - `TiktokProfiles`, `TiktokPosts`: TikTok profile/post management
  - `Tags`: Tag management
- **Features**: Filters, scopes, batch actions, member actions, custom index/show pages

### Data Flow Architecture

#### Profile Update Flow (Instagram/TikTok)
```
1. Rake Task / Admin Action
   ↓
2. Service: GetProfileData.call(username)
   → Fetches raw API response
   ↓
3. Service: UpdateProfileData.call(raw_data)
   → Transforms to model attributes hash
   ↓
4. Model: profile.update!(attributes)
   → Persists to database
   ↓
5. Model: profile.save_avatar
   → Downloads image via ImageDownloader concern
   → Attaches via ActiveStorage
   ↓
6. Model: profile.data = raw_data
   → Stores full API response (via JsonDataSetter concern)
```

#### Post Update Flow (Instagram/TikTok)
```
1. Rake Task / Admin Action
   ↓
2. Service: GetPostsData.call(profile)
   → Fetches posts array from API
   ↓
3. For each post:
   a. Service: UpdatePostData.call(post_data)
      → Transforms to post attributes hash
   b. Model: post.find_or_create_by!(identifier)
      → Finds or creates post record
   c. Model: post.update!(attributes)
      → Persists to database
   d. Model: post.save_image / post.save_cover
      → Downloads image via ImageDownloader concern
      → Attaches via ActiveStorage
```

### Error Handling Architecture

#### Error Classification Pattern
- **ErrorClassifier Services**: Categorize errors as permanent/temporary/unknown
- **Permanent Errors**: Profile doesn't exist, account deleted → Disable profile
- **Temporary Errors**: Rate limits, timeouts → Log and retry later
- **Unknown Errors**: Treated as temporary (conservative approach)

#### Error Flow in Rake Tasks
```
1. API Call fails
   ↓
2. ErrorClassifier.describe(error_message)
   → Returns { type: :permanent/:temporary/:unknown, action: ..., user_message: ... }
   ↓
3. Case statement on error type:
   - :permanent → profile.update!(enabled: false)
   - :temporary → log error, continue
   - :unknown → log error, continue (conservative)
```

### Background Processing Architecture

#### Rake Tasks (`lib/tasks/`)
- **Parallel Processing**: Uses `Parallel` gem for concurrent execution
- **Instagram Tasks**:
  - `update_profiles`: 10 parallel processes
  - `update_posts`: 10 parallel processes
  - `update_profile_posts`: Single profile processing
  - `update_profiles_stats`: Aggregated statistics
  - `create_daily_stats`: Daily snapshots
- **TikTok Tasks**:
  - `update_profiles`: 10 parallel processes
  - `update_posts`: 5 parallel processes
- **Scheduled Tasks** (`config/schedule.rb`):
  - Uses `whenever` gem for cron scheduling
  - Instagram: 3h, 6h, 12h, 24h intervals
  - TikTok: Daily at midnight

### API Architecture

#### RESTful API (`/api/v1/`)
- **Authentication**: Token-based via `Api::V1::Authenticable` concern
- **Endpoints**:
  - `GET /api/v1/profiles/search` - Search profiles
  - `GET /api/v1/profiles/:username` - Get profile data
  - `GET /api/v1/profiles/:username/posts` - Get profile posts
- **Serializers**: Custom serializers in `app/serializers/` for JSON formatting
- **Response Format**: JSON with standardized error handling

### Storage Architecture

#### Active Storage
- **Storage Backend**: Local filesystem (development/production)
- **Configuration**: `config/storage.yml`
- **Direct Blob Serving**: Custom `BlobFilesController` serves blobs directly
  - Route: `GET /blob_files/:dir1/:dir2/:key`
  - Path structure: `/blob_files/{key[0..1]}/{key[2..3]}/{key}`
  - Cache headers: `Cache-Control: public, max-age=31536000`
- **Image Download Flow**:
  1. Model calls `download_and_attach_image` (from `ImageDownloader` concern)
  2. HTTParty downloads image from URL
  3. Image attached via ActiveStorage
  4. Served via `BlobFilesController` or Rails default route

### Caching Strategy

#### HTTP Caching
- **Conditional GETs**: Controllers use `fresh_when` for ETag/Last-Modified caching
- **Example**: `TiktokProfilesController#show` uses `fresh_when last_modified: @tiktok_profile.updated_at.utc, etag: @tiktok_profile`

#### Image Caching
- **Direct Blob URLs**: Long cache headers (1 year) for static images
- **CDN-Ready**: Blob file structure supports CDN integration

### Routing Architecture

#### Route Structure
- **Public Routes**: RESTful resources (`profiles`, `tiktok_profiles`, `posts`, `tags`)
- **Admin Routes**: ActiveAdmin handles `/admin/*` routes
- **API Routes**: Namespaced under `/api/v1/*`
- **Custom Routes**: Category pages, legal pages, error pages
- **Blob Serving**: Custom route for ActiveStorage blobs

### Configuration Architecture

#### Initializers (`config/initializers/`)
- **Service Configs**: `instagram_config.rb`, `tiktok_config.rb` - API configuration
- **ActiveAdmin**: Admin interface configuration
- **Devise**: Authentication configuration
- **Meta Tags**: SEO configuration
- **Site Config**: Application-wide settings

### Testing Architecture

#### Test Structure (`test/`)
- **Unit Tests**: Model tests
- **Integration Tests**: Controller tests
- **System Tests**: End-to-end tests
- **Fixtures**: Test data fixtures

### Key Architectural Patterns

1. **Service Object Pattern**: Encapsulates external API logic and data transformation
2. **Concern Pattern**: Shared functionality extracted into reusable concerns
3. **Repository Pattern**: Models act as repositories for data access
4. **Strategy Pattern**: Error classification strategies via `ErrorClassifier`
5. **Template Method Pattern**: `ApplicationService` defines service interface
6. **Observer Pattern**: Model callbacks (`after_create`, `touch: true`)

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
  - Includes concerns: `JsonDataSetter`, `ImageDownloader`, `ReachCalculator`
  - Scopes: `enabled`, `disabled`, `paraguayos`, `otros`, `micro`, `macro`, `tracked`, `marcas`, `medios`
  - Methods: `update_from_api_data`, `update_profile`, `update_posts`, `save_avatar`, `calculate_estimated_reach`, `calculate_estimated_reach_percentage`
  - Uses `TiktokServices::UpdateProfileData` service for data transformation
  - After create callback: `update_profile`

- **TiktokPost** (`app/models/tiktok_post.rb`):
  - Stores individual TikTok video posts
  - Fields: `tiktok_post_id`, `desc`, `posted_at`, `likes_count`, `comments_count`, `play_count`, `shares_count`, `collects_count`, `total_count`, `cover_url`, `video_url`, `music_title`, `data` (JSON)
  - Belongs to `tiktok_profile`
  - Has one attached `cover` (ActiveStorage)
  - Includes concerns: `JsonDataSetter`, `ImageDownloader`
  - Scopes: `a_day_ago`, `a_week_ago`, `a_month_ago`
  - Methods: `update_from_api_data`, `save_cover`, `update_total_count`
  - Uses `TiktokServices::UpdatePostData` service for data transformation

### Services

- **TiktokServices::Base** (`app/services/tiktok_services/base.rb`):

  - Base class for all TikTok services, inherits from `ApplicationService`
  - Provides: `make_request`, `parse_response`, `with_retry`, `log_api_call`, `safe_integer`, `parse_timestamp`
  - Custom exceptions: `InvalidUsernameError`, `APIError`, `TimeoutError`, `ParseError`
  - Uses `TikTokConfig` for API configuration
  - Helper methods: `safe_integer` (converts values to integers safely), `parse_timestamp` (converts Unix timestamps to Time objects)

- **TiktokServices::GetProfileData** (`app/services/tiktok_services/get_profile_data.rb`):

  - Fetches TikTok profile data by username
  - Endpoint: `/public/check`
  - Returns profile information including `secUid` needed for posts
  - Returns raw API response data

- **TiktokServices::UpdateProfileData** (`app/services/tiktok_services/update_profile_data.rb`):

  - Parses and transforms raw TikTok profile data
  - Extracts relevant fields: username, unique_id, nickname, followers, following, hearts, verified status, avatar URLs, stats
  - Validates required fields (`userInfo` structure)
  - Returns hash with profile attributes ready for database update
  - Inherits helper methods from `TiktokServices::Base`

- **TiktokServices::GetPostsData** (`app/services/tiktok_services/get_posts_data.rb`):

  - Fetches TikTok feed posts for a user
  - Endpoint: `/public/posts`
  - Accepts `secUid` (can resolve from `TiktokProfile` or username)
  - Defaults to 30 posts per page
  - Returns `itemList` array with post data

- **TiktokServices::UpdatePostData** (`app/services/tiktok_services/update_post_data.rb`):

  - Parses and transforms raw TikTok post data
  - Extracts: post ID, description, timestamps, engagement metrics (likes, comments, views, shares, collects), video URLs, cover URLs, music info
  - Validates required fields (`id`, `createTime`)
  - Returns hash with post attributes ready for database update
  - Inherits helper methods from `TiktokServices::Base`

- **TiktokServices::ErrorClassifier** (`app/services/tiktok_services/error_classifier.rb`):
  - Classifies TikTok API errors as permanent, temporary, or unknown
  - Helps decide whether to disable profiles or retry operations
  - Similar to `InstagramServices::ErrorClassifier`
  - Permanent errors: user not found, profile not found, invalid username, account banned/deleted
  - Temporary errors: rate limits, timeouts, network errors, service unavailable (5xx)
  - Unknown errors: treated as temporary (conservative approach)
  - Returns hash with `:type`, `:user_message`, `:action`, `:retry` keys

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
  - Calculates metrics for last week posts: total posts count, total interactions, play count, likes, comments, shares
  - Calculates estimated reach using `TiktokProfile#calculate_estimated_reach` (from `ReachCalculator` concern)
  - Uses conditional GETs for caching (`fresh_when`)
  - Follows "fat model, skinny controller" principle - business logic in model concerns

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
  - Two-step process: `TiktokServices::GetProfileData` → `TiktokServices::UpdateProfileData`
  - Updates profile data and saves avatars automatically
  - Uses `TiktokServices::ErrorClassifier` to handle errors:
    - Permanent errors: automatically disables profile (`enabled: false`)
    - Temporary errors: logs error but doesn't disable (retry later)
    - Unknown errors: treated as temporary (conservative approach)
  - Shows summary with success/error/disabled counts

- **tiktok:update_posts** (`lib/tasks/tiktok/update_posts.rake`):
  - Updates posts for all tracked TikTok profiles
  - Uses parallel processing (5 processes)
  - Calls `TiktokServices::GetPostsData` for each profile
  - For each post: `TiktokServices::UpdatePostData` → saves post → saves cover
  - Uses `TiktokServices::ErrorClassifier` to handle errors:
    - Permanent errors: automatically disables profile
    - Temporary errors: logs error and continues
  - Shows summary with posts updated/created counts and disabled profiles count

### Image Storage

- **Local Image Storage**: TikTok avatars and post covers are saved locally using ActiveStorage
  - Avatars: `TiktokProfile#save_avatar` downloads from `avatar_larger` URL
  - Covers: `TiktokPost#save_cover` downloads from `cover_url`
  - Both methods check if already attached before downloading
  - Images are served via direct blob URLs (`/blob_files/...`) for better caching
  - Helper: `StorageHelper#direct_blob_url` generates URLs in format `/blob_files/{key[0..1]}/{key[2..3]}/{key}`

### Concerns

- **JsonDataSetter** (`app/models/concerns/json_data_setter.rb`):

  - Handles JSON data field setters that accept both Hash and JSON string inputs
  - Used by `TiktokProfile` and `TiktokPost` models
  - Handles data from Active Admin forms (JSON strings) and API responses (Hashes)
  - Gracefully handles JSON parsing errors (defaults to empty hash)

- **ImageDownloader** (`app/models/concerns/image_downloader.rb`):

  - Handles downloading and attaching images from URLs
  - Used by `TiktokProfile` (for avatars) and `TiktokPost` (for covers)
  - Method: `download_and_attach_image(url, attachment_name, filename, placeholder_url: nil)`
  - Checks if already attached before downloading
  - Supports optional placeholder URL if download fails
  - Uses HTTParty for HTTP requests

- **ReachCalculator** (`app/models/concerns/reach_calculator.rb`):
  - Calculates estimated reach for influencer profiles
  - Used by `TiktokProfile` model
  - Uses hybrid method combining follower-based and interaction-based calculations
  - Methods: `calculate_estimated_reach(total_interactions:, total_posts:)`, `calculate_estimated_reach_percentage(total_interactions:, total_posts:)`
  - Constants: `ENGAGEMENT_RATE` (0.15), `INTERACTION_TO_REACH_MULTIPLIER` (10), `FOLLOWER_WEIGHT` (0.6), `INTERACTION_WEIGHT` (0.4), `MAX_REACH_PERCENTAGE` (0.5)
  - Max cap: never more than 50% of followers

### Data Access & Storage Flow

**Profile Data:**

1. `TiktokServices::GetProfileData.call(username: 'username')` → Fetches raw profile data from tikAPI.io `/public/check` endpoint
2. `TiktokServices::UpdateProfileData.call(raw_data)` → Transforms raw data to profile attributes
3. `profile.update!(attributes)` → Updates database fields
4. `profile.save_avatar` → Downloads and saves avatar image via ActiveStorage (uses `ImageDownloader` concern)
5. Full API response stored in `profile.data` (JSON field, handled by `JsonDataSetter` concern)

**Post Data:**

1. `TiktokServices::GetPostsData.call(sec_uid: sec_uid)` or `.call(username: 'username')` → Fetches posts from tikAPI.io `/public/posts` endpoint
2. For each post in `itemList`:
   - `post.find_or_create_by!(tiktok_post_id:)` → Finds or creates post record
   - `TiktokServices::UpdatePostData.call(post_data)` → Transforms raw data to post attributes
   - `post.update!(attributes)` → Updates database fields
   - `post.save_cover` → Downloads and saves cover image via ActiveStorage (uses `ImageDownloader` concern)
3. Full API response stored in `post.data` (JSON field, handled by `JsonDataSetter` concern)

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
  # Get profile data (two-step process)
  result = TiktokServices::GetProfileData.call(username: 'username')
  if result.success?
    update_result = TiktokServices::UpdateProfileData.call(result.data)
    if update_result.success?
      profile.update!(update_result.data)
      profile.save_avatar # Automatically downloads and saves avatar
    end
  end

  # Get posts data
  result = TiktokServices::GetPostsData.call(sec_uid: profile.sec_uid)
  # or
  result = TiktokServices::GetPostsData.call(username: 'username')
  if result.success?
    result.data.each do |post_data|
      update_result = TiktokServices::UpdatePostData.call(post_data)
      if update_result.success?
        post = profile.tiktok_posts.find_or_create_by!(tiktok_post_id: post_data['id'])
        post.update!(update_result.data)
        post.save_cover # Automatically downloads and saves cover
      end
    end
  end

  # Error classification
  error_description = TiktokServices::ErrorClassifier.describe(error_message)
  case error_description[:type]
  when :permanent
    profile.update!(enabled: false) # Disable profile
  when :temporary, :unknown
    # Log error, retry later
  end

  # Calculate estimated reach
  reach = profile.calculate_estimated_reach(
    total_interactions: total_interactions_count,
    total_posts: total_posts_count
  )
  reach_percentage = profile.calculate_estimated_reach_percentage(
    total_interactions: total_interactions_count,
    total_posts: total_posts_count
  )
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
- `app/models/concerns/json_data_setter.rb`, `app/models/concerns/image_downloader.rb`, `app/models/concerns/reach_calculator.rb`
- `app/controllers/tiktok_profiles_controller.rb`, `app/controllers/blob_files_controller.rb`
- `app/services/tiktok_services/base.rb`, `app/services/tiktok_services/get_profile_data.rb`, `app/services/tiktok_services/update_profile_data.rb`, `app/services/tiktok_services/get_posts_data.rb`, `app/services/tiktok_services/update_post_data.rb`, `app/services/tiktok_services/error_classifier.rb`
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

