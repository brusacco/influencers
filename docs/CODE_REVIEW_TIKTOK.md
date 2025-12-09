# Code Review: TikTok Integration

**Review Date**: 2024-11-28  
**Reviewer**: Senior Rails Developer  
**Scope**: TikTok integration (services, models, controllers, rake tasks)

---

## Overall Assessment

**Rating: 🟢 Clean with Minor Improvements Needed**

The TikTok integration follows Rails best practices and maintains consistency with the existing Instagram implementation. The code is well-structured, follows DRY principles, and demonstrates proper separation of concerns. There are a few areas for improvement, but overall the implementation is production-ready.

---

## 🧩 Separation of Concerns

### ✅ **Strengths**

1. **Service Layer Pattern**: Excellent separation between API fetching (`GetProfileData`, `GetPostsData`) and data transformation (`UpdateProfileData`, `UpdatePostData`). This follows the Single Responsibility Principle.

2. **Controller Logic**: `TiktokProfilesController` is appropriately thin:
   - Delegates business logic to models/services
   - Uses concerns (`StorageHelper`, `SeoConcern`) appropriately
   - Calculates metrics in controller (acceptable for presentation logic)

3. **Model Responsibilities**: Models handle their own data persistence and business rules:
   - `TiktokProfile` manages profile updates and post fetching
   - `TiktokPost` handles post data transformation

### ⚠️ **Issues Found**

1. **Controller Contains Business Logic** (`TiktokProfilesController#calculate_estimated_reach`)
   ```ruby
   # Line 38-54: Business logic in controller
   def calculate_estimated_reach
     # Complex calculation logic...
   end
   ```
   **Recommendation**: Move to `TiktokProfile` model or create a `MetricsCalculator` service object. This logic is duplicated from `Profile` model.

2. **Model Contains API Logic** (`TiktokProfile#update_posts`)
   ```ruby
   # Line 144-176: Model orchestrating API calls
   def update_posts
     result = TiktokServices::GetPostsData.call(self)
     # ... processes posts
   end
   ```
   **Recommendation**: Consider extracting to a service object like `TiktokServices::SyncProfilePosts` to keep models focused on data persistence.

---

## 🔁 DRY Principles

### ✅ **Strengths**

1. **Shared Base Service**: `TiktokServices::Base` provides common functionality (retry logic, error handling, logging).

2. **Consistent Service Pattern**: All services follow the same structure (initialize → call → handle_success/error).

3. **Reusable Helpers**: `safe_dig`, `safe_integer`, `parse_timestamp` methods are well-placed.

### ⚠️ **Issues Found**

1. **Duplicated `safe_integer` Method**
   ```ruby
   # Found in both:
   # - app/services/tiktok_services/update_profile_data.rb (line 119)
   # - app/services/tiktok_services/update_post_data.rb (line 111)
   ```
   **Recommendation**: Move to `TiktokServices::Base` or create a shared concern:
   ```ruby
   # In TiktokServices::Base
   def safe_integer(value)
     return 0 if value.nil?
     Integer(value)
   rescue ArgumentError, TypeError
     0
   end
   ```

2. **Duplicated `parse_timestamp` Method**
   ```ruby
   # Found in:
   # - app/services/tiktok_services/update_post_data.rb (line 99)
   # - app/services/instagram_services/update_post_data.rb (line 138)
   ```
   **Recommendation**: Extract to `ApplicationService` base class or shared concern.

3. **Duplicated `data=` Setter**
   ```ruby
   # Identical implementation in:
   # - TiktokProfile (line 35-56)
   # - TiktokPost (line 15-36)
   ```
   **Recommendation**: Extract to a concern:
   ```ruby
   # app/models/concerns/json_data_setter.rb
   module JsonDataSetter
     extend ActiveSupport::Concern
     
     included do
       # Custom setter logic here
     end
   end
   ```

4. **Duplicated `save_avatar` Logic**
   ```ruby
   # Similar patterns in:
   # - TiktokProfile#save_avatar (line 108-121)
   # - Profile#save_avatar (line 145-155)
   # - InstagramPost#save_image (line 123-134)
   # - TiktokPost#save_cover (line 79-95)
   ```
   **Recommendation**: Create a shared concern `ImageDownloader` or use ActiveStorage's built-in URL attachment:
   ```ruby
   module ImageDownloader
     def download_and_attach_image(url, attachment_name, filename)
       return if send(attachment_name).attached?
       return if url.blank?
       
       # Common download logic
     end
   end
   ```

5. **Duplicated Validation Logic**
   ```ruby
   # Similar validation in:
   # - TiktokServices::GetProfileData#validate_response_structure! (line 57)
   # - TiktokServices::GetPostsData#validate_response_structure! (line 98)
   ```
   **Recommendation**: Extract to `TiktokServices::Base`:
   ```ruby
   def validate_tiktok_response!(data, required_key: nil)
     # Common validation logic
   end
   ```

---

## 🧼 Code Quality & Clean Code

### ✅ **Strengths**

1. **Clear Naming**: Method and variable names are descriptive (`update_from_api_data`, `display_username`, `calculate_estimated_reach`).

2. **Good Documentation**: Services have YARD comments explaining usage and parameters.

3. **Consistent Error Handling**: All services use the same error handling pattern.

4. **Proper Use of Rails Conventions**: Scopes, validations, associations follow Rails idioms.

### ⚠️ **Issues Found**

1. **Inconsistent Error Handling in Models**
   ```ruby
   # TiktokProfile#save_avatar (line 119)
   Rails.logger.warn("Failed to save TikTok avatar...")
   
   # Profile#save_avatar (line 154)
   puts e.message  # ❌ Should use logger
   ```
   **Recommendation**: Standardize on `Rails.logger` throughout.

2. **Magic Numbers**
   ```ruby
   # TiktokProfilesController#calculate_estimated_reach (line 42, 45, 48, 51)
   follower_based_reach = @tiktok_profile.followers * 0.15  # Magic number
   interaction_based_reach = @total_interactions_count * 10  # Magic number
   weighted_reach = (follower_based_reach * 0.6) + (interaction_based_reach * 0.4)  # Magic numbers
   max_reach = @tiktok_profile.followers * 0.5  # Magic number
   ```
   **Recommendation**: Extract to constants:
   ```ruby
   ENGAGEMENT_RATE = 0.15
   INTERACTION_TO_REACH_MULTIPLIER = 10
   FOLLOWER_WEIGHT = 0.6
   INTERACTION_WEIGHT = 0.4
   MAX_REACH_PERCENTAGE = 0.5
   ```

3. **Hardcoded Sleep in Rake Task**
   ```ruby
   # lib/tasks/tiktok/update_profiles.rake (line 31)
   sleep 1  # Hardcoded delay
   ```
   **Recommendation**: Use configuration:
   ```ruby
   sleep TikTokConfig::RATE_LIMIT_DELAY || 1
   ```

4. **Inconsistent Return Values**
   ```ruby
   # TiktokProfile#update_posts returns Hash
   { success: true, posts_updated: 1, ... }
   
   # TiktokProfile#update_profile returns nil/void
   # Should be consistent
   ```
   **Recommendation**: Standardize return values or use a result object pattern.

5. **Missing Null Checks**
   ```ruby
   # TiktokPost#save_cover (line 84)
   filename = "#{tiktok_post_id}.jpg"
   # What if tiktok_post_id is nil?
   ```
   **Recommendation**: Add validation or null check.

---

## 🧭 Rails Best Practices

### ✅ **Strengths**

1. **Fat Models / Skinny Controllers**: ✅ Controllers are appropriately thin.

2. **RESTful Routes**: ✅ Routes follow REST conventions.

3. **Proper Use of Scopes**: ✅ Well-defined scopes for filtering.

4. **Validations**: ✅ Appropriate validations on models.

5. **Callbacks**: ✅ Appropriate use of `after_create` callback.

6. **ActiveStorage**: ✅ Proper use of `has_one_attached`.

### ⚠️ **Issues Found**

1. **Callback May Fail Silently**
   ```ruby
   # TiktokProfile (line 13)
   after_create :update_profile
   ```
   **Issue**: If `update_profile` fails, the record is still created. This could lead to incomplete data.
   **Recommendation**: 
   ```ruby
   after_create :update_profile, if: -> { username.present? }
   # Or use background job:
   after_create :enqueue_profile_update, if: -> { username.present? }
   ```

2. **Missing Transaction Wrapping**
   ```ruby
   # TiktokProfile#update_posts (line 154-168)
   result.data.each do |post_data|
     post = tiktok_posts.find_or_initialize_by(...)
     post.update_from_api_data(post_data)  # No transaction
   end
   ```
   **Recommendation**: Wrap in transaction for atomicity:
   ```ruby
   transaction do
     result.data.each do |post_data|
       # ...
     end
   end
   ```

3. **Potential N+1 in Controller**
   ```ruby
   # TiktokProfilesController#show (line 14-15)
   @posts = @tiktok_profile.tiktok_posts.order(posted_at: :desc).limit(50)
   @last_week_posts = @tiktok_profile.tiktok_posts.a_week_ago
   ```
   **Issue**: Two separate queries. Could be optimized.
   **Recommendation**: 
   ```ruby
   posts_relation = @tiktok_profile.tiktok_posts.order(posted_at: :desc)
   @posts = posts_relation.limit(50)
   @last_week_posts = posts_relation.a_week_ago
   ```

4. **Missing Indexes**
   ```ruby
   # Check if these queries are optimized:
   # - TiktokProfile.enabled.paraguayos.order(followers: :desc)
   # - tiktok_posts.a_week_ago
   ```
   **Recommendation**: Verify indexes exist for:
   - `tiktok_profiles.enabled`
   - `tiktok_profiles.country_string`
   - `tiktok_profiles.followers`
   - `tiktok_posts.posted_at`
   - `tiktok_posts.tiktok_profile_id`

5. **Missing Strong Parameters Documentation**
   ```ruby
   # TiktokProfilesController has no params method
   # But it's a read-only controller, so this is acceptable
   ```

---

## ⚙️ Performance & Scalability

### ✅ **Strengths**

1. **Parallel Processing**: ✅ Rake tasks use `Parallel.map` for concurrent execution.

2. **Conditional GETs**: ✅ Controller uses `fresh_when` for HTTP caching.

3. **Eager Loading**: ✅ Uses `find_or_initialize_by` appropriately.

### ⚠️ **Issues Found**

1. **N+1 Query Risk in Rake Task**
   ```ruby
   # lib/tasks/tiktok/update_posts.rake (line 31)
   post = profile.tiktok_posts.find_or_initialize_by(tiktok_post_id: post_id)
   ```
   **Issue**: In parallel processing, each profile loads posts individually.
   **Recommendation**: Preload posts if processing multiple profiles:
   ```ruby
   profiles = TiktokProfile.tracked.includes(:tiktok_posts).order(...)
   ```

2. **Inefficient Array Operations**
   ```ruby
   # lib/tasks/tiktok/update_posts.rake (line 64)
   total_posts = results.sum { |r| r[:posts_updated] }
   ```
   **Issue**: `sum` with block is less efficient than direct access.
   **Recommendation**: Use `sum` with symbol:
   ```ruby
   total_posts = results.sum { |r| r[:posts_updated] }  # Current
   # Better: results.sum { |r| r.dig(:posts_updated) || 0 }
   ```

3. **Memory Usage in Rake Tasks**
   ```ruby
   # lib/tasks/tiktok/update_profiles.rake (line 6)
   profiles = TiktokProfile.enabled.paraguayos.order(followers: :desc).to_a
   ```
   **Issue**: Loads all profiles into memory at once.
   **Recommendation**: Use `find_each` for large datasets:
   ```ruby
   # For large datasets:
   TiktokProfile.enabled.paraguayos.find_each(batch_size: 100) do |profile|
     # Process in batches
   end
   ```

4. **No Rate Limiting Protection**
   ```ruby
   # Parallel processing with 10 processes, but no rate limiting
   Parallel.map(profiles, in_processes: 10) do |profile|
     # API calls without rate limiting
   end
   ```
   **Recommendation**: Add rate limiting or reduce parallel processes:
   ```ruby
   # Add delays or use a rate limiter gem
   sleep TikTokConfig::RATE_LIMIT_DELAY if index > 0
   ```

5. **BlobFilesController Performance**
   ```ruby
   # app/controllers/blob_files_controller.rb (line 30)
   blob = ActiveStorage::Blob.find_by(key: key)
   ```
   **Issue**: Database query on every file request.
   **Recommendation**: Cache blob lookup or use filesystem metadata:
   ```ruby
   # Consider caching or using Rails.cache
   blob = Rails.cache.fetch("blob_#{key}", expires_in: 1.hour) do
     ActiveStorage::Blob.find_by(key: key)
   end
   ```

---

## 🧠 Maintainability

### ✅ **Strengths**

1. **Consistent Patterns**: Code follows the same patterns as Instagram integration, making it easy to understand.

2. **Good Documentation**: Services are well-documented with examples.

3. **Error Handling**: Comprehensive error handling with specific exception types.

4. **Modular Design**: Services can be tested independently.

### ⚠️ **Issues Found**

1. **Tight Coupling Between Services**
   ```ruby
   # TiktokServices::GetPostsData (line 70)
   profile_result = GetProfileData.call(username: @username)
   ```
   **Issue**: `GetPostsData` directly calls `GetProfileData`, creating coupling.
   **Recommendation**: Inject dependency or use a resolver service:
   ```ruby
   class SecUidResolver
     def self.resolve(profile:, sec_uid:, username:)
       # Centralized resolution logic
     end
   end
   ```

2. **Hard to Test `update_from_api_data`**
   ```ruby
   # TiktokProfile#update_from_api_data (line 62-72)
   def update_from_api_data(api_data)
     result = TiktokServices::UpdateProfileData.call(api_data)
     # ...
   end
   ```
   **Issue**: Method calls service directly, making unit testing harder.
   **Recommendation**: Consider dependency injection or make service call explicit in tests.

3. **Missing Error Classification**
   ```ruby
   # Unlike Instagram, TikTok doesn't have ErrorClassifier
   # Rake tasks don't distinguish permanent vs temporary errors
   ```
   **Recommendation**: Create `TiktokServices::ErrorClassifier` similar to Instagram:
   ```ruby
   module TiktokServices
     class ErrorClassifier
       def self.describe(error_message)
         # Classify errors as permanent/temporary
       end
     end
   end
   ```

4. **Configuration Scattered**
   ```ruby
   # Hardcoded values in multiple places:
   # - Rake tasks: sleep 1, in_processes: 10
   # - Services: count: 30
   ```
   **Recommendation**: Centralize in `TikTokConfig`:
   ```ruby
   module TikTokConfig
     RATE_LIMIT_DELAY = 1
     PARALLEL_PROCESSES = 10
     DEFAULT_POST_COUNT = 30
   end
   ```

---

## 📋 Specific Issues Summary

### 🔴 **Critical Issues** (Fix Immediately)

1. **None** - Code is production-ready

### 🟡 **Important Issues** (Fix Soon)

1. **Extract Duplicated Methods**: `safe_integer`, `parse_timestamp`, `data=` setter
2. **Move Business Logic**: `calculate_estimated_reach` to model or service
3. **Add Error Classification**: Create `TiktokServices::ErrorClassifier`
4. **Improve Error Handling**: Standardize on `Rails.logger` instead of `puts`
5. **Add Rate Limiting**: Protect against API rate limits

### 🟢 **Nice to Have** (Improve Over Time)

1. **Extract Magic Numbers**: Move to constants
2. **Add Transaction Wrapping**: For atomic operations
3. **Optimize Queries**: Reduce N+1 risks
4. **Add Caching**: For blob lookups
5. **Improve Testability**: Consider dependency injection

---

## 🎯 Concrete Recommendations

### Priority 1: Extract Shared Code

**Create `app/models/concerns/json_data_setter.rb`**:
```ruby
module JsonDataSetter
  extend ActiveSupport::Concern

  included do
    def data=(value)
      case value
      when Hash
        super(value)
      when String
        super(value.blank? ? {} : JSON.parse(value.strip))
      else
        super({})
      end
    rescue JSON::ParserError => e
      Rails.logger.warn("Failed to parse data JSON: #{e.message}")
      super({})
    end
  end
end
```

**Update `TiktokServices::Base`**:
```ruby
def safe_integer(value)
  return 0 if value.nil?
  Integer(value)
rescue ArgumentError, TypeError
  0
end

def parse_timestamp(timestamp)
  return nil if timestamp.nil?
  Time.zone.at(Integer(timestamp))
rescue ArgumentError, TypeError => e
  Rails.logger.error("Invalid timestamp: #{timestamp}")
  raise ArgumentError, "Invalid timestamp: #{e.message}"
end
```

### Priority 2: Move Business Logic

**Create `app/models/concerns/reach_calculator.rb`**:
```ruby
module ReachCalculator
  extend ActiveSupport::Concern

  ENGAGEMENT_RATE = 0.15
  INTERACTION_TO_REACH_MULTIPLIER = 10
  FOLLOWER_WEIGHT = 0.6
  INTERACTION_WEIGHT = 0.4
  MAX_REACH_PERCENTAGE = 0.5

  def calculate_estimated_reach(total_interactions:, total_posts:)
    return 0 if followers.zero? || total_posts.zero?

    follower_based_reach = followers * ENGAGEMENT_RATE
    interaction_based_reach = total_interactions * INTERACTION_TO_REACH_MULTIPLIER
    weighted_reach = (follower_based_reach * FOLLOWER_WEIGHT) + 
                     (interaction_based_reach * INTERACTION_WEIGHT)
    max_reach = followers * MAX_REACH_PERCENTAGE

    [weighted_reach, max_reach].min.round
  end
end
```

**Update Controller**:
```ruby
# In TiktokProfilesController
@estimated_reach = @tiktok_profile.calculate_estimated_reach(
  total_interactions: @total_interactions_count,
  total_posts: @total_posts_count
)
```

### Priority 3: Add Error Classification

**Create `app/services/tiktok_services/error_classifier.rb`**:
```ruby
module TiktokServices
  class ErrorClassifier
    PERMANENT_ERROR_PATTERNS = [
      /user not found/i,
      /profile not found/i,
      /invalid username/i,
      /account banned/i
    ].freeze

    TEMPORARY_ERROR_PATTERNS = [
      /rate limit/i,
      /timeout/i,
      /network error/i,
      /temporary/i
    ].freeze

    def self.describe(error_message)
      error_lower = error_message.to_s.downcase

      if PERMANENT_ERROR_PATTERNS.any? { |pattern| error_lower.match?(pattern) }
        {
          type: :permanent,
          user_message: "Profile no longer exists or was deleted",
          action: :disable_profile
        }
      elsif TEMPORARY_ERROR_PATTERNS.any? { |pattern| error_lower.match?(pattern) }
        {
          type: :temporary,
          user_message: "Temporary error, will retry later",
          action: :retry
        }
      else
        {
          type: :unknown,
          user_message: "Unknown error occurred",
          action: :log_and_continue
        }
      end
    end
  end
end
```

### Priority 4: Improve Rake Tasks

**Update `lib/tasks/tiktok/update_profiles.rake`**:
```ruby
# Add error classification
error_info = TiktokServices::ErrorClassifier.describe(result.error)
case error_info[:type]
when :permanent
  profile.update!(enabled: false)
when :temporary
  # Log and continue
end

# Use configuration
sleep TikTokConfig::RATE_LIMIT_DELAY || 1
```

### Priority 5: Add Image Download Concern

**Create `app/models/concerns/image_downloader.rb`**:
```ruby
module ImageDownloader
  extend ActiveSupport::Concern

  def download_and_attach_image(url, attachment_name, filename, placeholder_url: nil)
    attachment = send(attachment_name)
    return if attachment.attached?
    return if url.blank?

    begin
      response = HTTParty.get(url)
      send(attachment_name).attach(
        io: StringIO.new(response.body),
        filename: filename
      )
    rescue StandardError => e
      Rails.logger.warn("Failed to download image: #{e.message}")
      return unless placeholder_url

      begin
        placeholder_response = HTTParty.get(placeholder_url)
        send(attachment_name).attach(
          io: StringIO.new(placeholder_response.body),
          filename: 'placeholder.jpg'
        )
      rescue StandardError
        # Silently fail
      end
    end
  end
end
```

---

## 📊 Code Quality Metrics

| Metric | Score | Notes |
|--------|-------|-------|
| **Separation of Concerns** | 8/10 | Minor issues with business logic in controller |
| **DRY Compliance** | 7/10 | Several duplicated methods need extraction |
| **Code Clarity** | 9/10 | Well-named, readable code |
| **Rails Conventions** | 9/10 | Follows Rails best practices |
| **Performance** | 7/10 | Some N+1 risks, but generally good |
| **Maintainability** | 8/10 | Good structure, needs error classification |
| **Testability** | 7/10 | Some tight coupling makes testing harder |

**Overall Score: 8.0/10** - Production-ready with recommended improvements

---

## ✅ Conclusion

The TikTok integration is **well-implemented** and follows Rails best practices. The code is clean, maintainable, and consistent with the existing Instagram implementation. The recommended improvements are primarily about reducing duplication and improving error handling, which will make the codebase even more maintainable as it grows.

**Key Strengths**:
- ✅ Excellent service layer architecture
- ✅ Consistent patterns with Instagram
- ✅ Good error handling
- ✅ Proper use of Rails conventions

**Areas for Improvement**:
- Extract duplicated code to shared concerns/modules
- Add error classification for better error handling
- Move business logic out of controllers
- Add rate limiting protection

The code is **ready for production** with the understanding that the recommended improvements should be addressed in future iterations.

