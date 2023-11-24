# frozen_string_literal: true

class InstagramPost < ApplicationRecord
  has_one_attached :image
  serialize :data, Hash
  belongs_to :profile
  has_many :instagram_collaborations, dependent: :destroy

  scope :a_day_ago, -> { where(posted_at: 1.day.ago..) }
  scope :a_week_ago, -> { where(posted_at: 1.week.ago..) }
  scope :a_month_ago, -> { where(posted_at: 1.month.ago..) }

  def self.ransackable_associations(_auth_object = nil)
    %w[image_attachment image_blob instagram_collaborations profile]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      caption
      comments_count
      created_at
      data
      id
      likes_count
      media
      blob_id
      posted_at
      product_type
      profile_id
      shortcode
      updated_at
      url
      video_view_count
    ]
  end

  def self.word_occurrences(limit = 100)
    word_occurrences = Hash.new(0)

    bads = %w[vos]

    all.find_each do |post|
      next if post.caption.nil?

      words = post.caption.split
      words.each do |word|
        cleaned_word = word.downcase
        next if STOP_WORDS.include?(cleaned_word)
        next if bads.include?(cleaned_word)
        next if cleaned_word.length <= 2
        next if cleaned_word.start_with?('http', 'https', 'www')

        word_occurrences[cleaned_word] += 1
      end
    end

    word_occurrences.select { |_word, count| count > 1 }
                    .sort_by { |_k, v| v }
                    .reverse
                    .take(limit)
  end

  def save_image(url)
    response = HTTParty.get(url)
    data = response.body
    filename = "#{shortcode}.jpg"
    image.attach(io: StringIO.new(data), filename: filename)
  end

  def update_total_count
    update!(total_count: likes_count + comments_count)
  end

  def collabs; end
end
