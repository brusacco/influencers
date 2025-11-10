# Serializers

This directory contains serializers organized by social network platform.

## Structure

```
app/serializers/
├── instagram/
│   └── serializers/
│       ├── base_serializer.rb      # Base class for Instagram serializers
│       ├── profile_serializer.rb   # Instagram profile serialization
│       └── post_serializer.rb      # Instagram post serialization
├── facebook/                        # Future: Facebook serializers
│   └── serializers/
├── twitter/                         # Future: Twitter/X serializers
│   └── serializers/
└── tiktok/                          # Future: TikTok serializers
    └── serializers/
```

## Naming Convention

- **Namespace:** `[Network]::Serializers`
- **Class Name:** `[Model]Serializer`
- **Example:** `Instagram::Serializers::ProfileSerializer`

## Usage

### Single Object Serialization

```ruby
profile = Profile.find_by(username: 'john_doe')
Instagram::Serializers::ProfileSerializer.new(profile).as_json
```

### Collection Serialization

```ruby
posts = profile.instagram_posts.limit(10)
Instagram::Serializers::PostSerializer.collection(posts)
```

### With Options

```ruby
# Include related profile data
Instagram::Serializers::PostSerializer.collection(posts, include_profile: true)
```

## Creating New Serializers

### For Instagram

1. Create a new file in `app/serializers/instagram/serializers/`
2. Inherit from `Instagram::Serializers::BaseSerializer`
3. Implement the `as_json` method

```ruby
# app/serializers/instagram/serializers/story_serializer.rb
module Instagram
  module Serializers
    class StorySerializer < BaseSerializer
      def as_json
        {
          id: object.id,
          content: object.content,
          # ... more fields
        }
      end
    end
  end
end
```

### For a New Network (e.g., TikTok)

1. Create directory structure: `app/serializers/tiktok/serializers/`
2. Create base serializer: `tiktok/serializers/base_serializer.rb`
3. Create specific serializers inheriting from the base

```ruby
# app/serializers/tiktok/serializers/base_serializer.rb
module TikTok
  module Serializers
    class BaseSerializer
      attr_reader :object

      def initialize(object)
        @object = object
      end

      def as_json
        raise NotImplementedError
      end

      def self.collection(objects)
        objects.map { |obj| new(obj).as_json }
      end
    end
  end
end
```

## Best Practices

1. **Keep serializers focused**: Each serializer should handle one model
2. **Use base classes**: Share common functionality through inheritance
3. **Document options**: If your serializer accepts options, document them
4. **Avoid business logic**: Serializers should only format data, not compute it
5. **Consider performance**: Be mindful of N+1 queries when serializing collections

## API Controllers

Controllers should reference serializers with full namespace:

```ruby
module Api
  module V1
    class ProfilesController < ApplicationController
      def show
        profile = Profile.find_by!(username: params[:username])
        render json: Instagram::Serializers::ProfileSerializer.new(profile).as_json
      end
    end
  end
end
```

## Testing

Create matching test files in `test/serializers/`:

```
test/serializers/
├── instagram/
│   └── serializers/
│       ├── profile_serializer_test.rb
│       └── post_serializer_test.rb
```

Example test:

```ruby
require 'test_helper'

class Instagram::Serializers::ProfileSerializerTest < ActiveSupport::TestCase
  test "serializes profile correctly" do
    profile = profiles(:one)
    result = Instagram::Serializers::ProfileSerializer.new(profile).as_json
    
    assert_equal profile.username, result[:username]
    assert_equal profile.followers, result[:followers]
  end
end
```

