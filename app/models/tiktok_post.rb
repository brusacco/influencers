# frozen_string_literal: true

class TiktokPost < ApplicationRecord
  serialize :data, Hash
  belongs_to :tiktok_profile, touch: true

  scope :a_day_ago, -> { where(posted_at: 1.day.ago..) }
  scope :a_week_ago, -> { where(posted_at: 1.week.ago..) }
  scope :a_month_ago, -> { where(posted_at: 1.month.ago..) }

  validates :tiktok_post_id, uniqueness: true

  # Custom setter for data field to handle both Hash and JSON string inputs
  def data=(value)
    case value
    when Hash
      super(value)
    when String
      # Handle empty strings or whitespace-only strings
      if value.blank? || value.strip.empty?
        super({})
      else
        # Parse JSON string
        parsed = JSON.parse(value.strip)
        super(parsed.is_a?(Hash) ? parsed : {})
      end
    else
      # Handle nil or any other type - default to empty hash
      super({})
    end
  rescue JSON::ParserError => e
    # If JSON parsing fails, log and default to empty hash
    Rails.logger.warn("Failed to parse data JSON: #{e.message}") if Rails.logger
    super({})
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[tiktok_profile]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      caption
      comments_count
      collects_count
      created_at
      data
      desc
      id
      likes_count
      play_count
      posted_at
      shares_count
      tiktok_post_id
      tiktok_profile_id
      total_count
      updated_at
      video_url
    ]
  end

  # Extract data from API response and populate database fields
  # @param post_data [Hash] Post data from itemList array
  def update_from_api_data(post_data)
    stats = post_data['stats'] || {}
    video = post_data['video'] || {}
    music = post_data['music'] || {}

    self.tiktok_post_id = post_data['id']
    self.desc = post_data['desc']
    self.posted_at = Time.at(post_data['createTime']) if post_data['createTime']

    # Stats
    self.likes_count = stats['diggCount'] || 0
    self.comments_count = stats['commentCount'] || 0
    self.play_count = stats['playCount'] || 0
    self.shares_count = stats['shareCount'] || 0
    self.collects_count = stats['collectCount'] || 0
    self.total_count = likes_count + comments_count + shares_count + collects_count

    # Video info
    self.video_url = video['playAddr']
    self.cover_url = video['cover']
    self.dynamic_cover_url = video['dynamicCover']
    self.video_duration = video['duration']
    self.video_definition = video['definition'] || video['ratio']

    # Music info
    self.music_title = music['title']
    self.music_author = music['authorName']
    self.music_play_url = music['playUrl']

    # Store full data
    self.data = post_data

    save!
  end

  # Helper methods
  def caption
    desc
  end

  def video_view_count
    play_count
  end

  def update_total_count
    update!(total_count: likes_count + comments_count + shares_count + collects_count)
  end
end

