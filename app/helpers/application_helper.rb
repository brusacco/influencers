# frozen_string_literal: true

module ApplicationHelper
  def normalize_to_scale(value, max_value, min_value)
    # Ensure that max_value is greater than min_value to avoid division by zero
    # raise ArgumentError, 'max_value must be greater than min_value' if max_value <= min_value

    # Calculate the normalized value on a scale from 1 to 10
    normalized = (((value - min_value) * 9) / ((max_value - min_value) + 1))

    # Ensure the result is within the range [1, 10]
    normalized.clamp(1, 10)
  end

  # JSON-LD Structured Data Helpers
  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": SITE_NAME,
      "url": root_url,
      "logo": {
        "@type": "ImageObject",
        "url": "#{root_url}logo.png"
      },
      "description": DESCRIPTION,
      "address": {
        "@type": "PostalAddress",
        "addressCountry": "PY"
      },
      "sameAs": [
        "https://www.instagram.com/influencerspy",
        "https://www.facebook.com/influencerspy"
      ]
    }.to_json.html_safe
  end

  def website_schema
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": SITE_NAME,
      "url": root_url,
      "potentialAction": {
        "@type": "SearchAction",
        "target": {
          "@type": "EntryPoint",
          "urlTemplate": "#{profiles_url}?q={search_term_string}"
        },
        "query-input": "required name=search_term_string"
      }
    }.to_json.html_safe
  end

  def profile_schema(profile)
    return unless profile

    {
      "@context": "https://schema.org",
      "@type": "ProfilePage",
      "mainEntity": {
        "@type": "Person",
        "name": profile.full_name,
        "alternateName": "@#{profile.username}",
        "description": profile.biography,
        "image": direct_blob_url(profile.avatar),
        "sameAs": "https://www.instagram.com/#{profile.username}",
        "interactionStatistic": [
          {
            "@type": "InteractionCounter",
            "interactionType": "https://schema.org/FollowAction",
            "userInteractionCount": profile.followers
          },
          {
            "@type": "InteractionCounter",
            "interactionType": "https://schema.org/LikeAction",
            "userInteractionCount": profile.total_interactions_count
          }
        ]
      },
      "dateModified": profile.updated_at.iso8601
    }.to_json.html_safe
  end

  def breadcrumb_schema(items)
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items.map.with_index do |item, index|
        {
          "@type": "ListItem",
          "position": index + 1,
          "name": item[:name],
          "item": item[:url]
        }
      end
    }.to_json.html_safe
  end

  def top_tags(limit = 5)
    ActsAsTaggableOn::Tag
      .joins(:taggings)
      .joins("INNER JOIN profiles ON profiles.id = taggings.taggable_id AND taggings.taggable_type = 'Profile'")
      .where(profiles: { country_string: 'Paraguay', enabled: true })
      .select('tags.*, COUNT(taggings.id) as taggings_count')
      .group('tags.id')
      .order('taggings_count DESC')
      .limit(limit)
  end
end
