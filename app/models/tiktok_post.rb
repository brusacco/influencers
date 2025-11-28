# frozen_string_literal: true

class TiktokPost < ApplicationRecord
  include JsonDataSetter
  include ImageDownloader

  serialize :data, Hash
  has_one_attached :cover
  belongs_to :tiktok_profile, touch: true

  scope :a_day_ago, -> { where(posted_at: 1.day.ago..) }
  scope :a_week_ago, -> { where(posted_at: 1.week.ago..) }
  scope :a_month_ago, -> { where(posted_at: 1.month.ago..) }

  validates :tiktok_post_id, uniqueness: true

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
  # Uses UpdatePostData service to transform raw data
  # @param post_data [Hash] Post data from itemList array
  def update_from_api_data(post_data)
    # Use UpdatePostData service to transform raw data
    result = TiktokServices::UpdatePostData.call(post_data)
    return unless result.success?

    # Update model with transformed attributes
    update!(result.data)
    
    # Save cover image locally after updating data
    save_cover
  end

  # Save cover image locally using ActiveStorage
  def save_cover
    return if cover.attached?
    return if cover_url.blank? || tiktok_post_id.blank?

    filename = "#{tiktok_post_id}.jpg"
    download_and_attach_image(
      cover_url,
      :cover,
      filename,
      placeholder_url: 'https://placehold.co/500x500/000000/FFFFFF/jpg'
    )
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

