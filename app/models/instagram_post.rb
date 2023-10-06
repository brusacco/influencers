# frozen_string_literal: true

class InstagramPost < ApplicationRecord
  serialize :data, Hash
  belongs_to :profile, touch: true

  scope :a_day_ago, -> { where(posted_at: 1.day.ago..) }
  scope :a_week_ago, -> { where(posted_at: 1.week.ago..) }
  scope :a_month_ago, -> { where(posted_at: 1.month.ago..) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      caption
      comments_count
      created_at
      data
      id
      image
      likes_count
      media
      posted_at
      product_type
      profile_id
      shortcode
      updated_at
      url
      video_view_count
    ]
  end

  def save_image(url)
    response = HTTParty.get(url)
    data = response.body
    update!(image: Base64.strict_encode64(data))
  end

  def update_total_count
    update!(total_count: likes_count + comments_count)
  end

  def collabs; end
end
