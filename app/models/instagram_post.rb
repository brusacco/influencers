# frozen_string_literal: true

class InstagramPost < ApplicationRecord
  has_one_attached :image
  serialize :data, Hash
  belongs_to :profile, touch: true
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

    find_each do |post|
      next if post.caption.nil?

      words = post.caption.gsub('.', '').split
      words.each do |word|
        cleaned_word = word.downcase
        next if STOP_WORDS.include?(cleaned_word)
        next if bads.include?(cleaned_word)
        next if cleaned_word.length <= 2
        next if cleaned_word.start_with?('http', 'https', 'www', 'whatsapp:', 'wa.me')
        next if cleaned_word.match?(/\A\d+\z/) # Checks if the word is a number
        next if cleaned_word.match?(/\A\d+\W+\d+\z/) # Checks if the word is a number
        next if cleaned_word.match?(/\(.*?\)/) # (xxxxxx)
        next if cleaned_word.include?('https://wame')

        word_occurrences[cleaned_word] += 1
      end
    end

    word_occurrences.select { |_word, count| count > 1 }
                    .sort_by { |_k, v| v }
                    .reverse
                    .take(limit)
  end

  def self.bigram_occurrences(limit = 100)
    word_occurrences = Hash.new(0)

    find_each do |post|
      next if post.caption.nil?

      words = post.caption.gsub('.', '').split
      bigrams = words.each_cons(2).map { |word1, word2| "#{word1.downcase} #{word2.downcase}" }
      bigrams.each do |bigram|
        next if bigram.split.first.length <= 2 || bigram.split.last.length <= 2
        next if STOP_WORDS.include?(bigram.split.first) || STOP_WORDS.include?(bigram.split.last)

        next if bigram.split.first.start_with?('http', 'https', 'www', 'whatsapp:', 'wame', 'wa.me', 'twitch:')
        next if bigram.split.first.match?(/\A\d+\z/) # Checks if the word is a number
        next if bigram.split.first.match?(/\A\d+\W+\d+\z/) # Checks if the word is a number
        next if bigram.split.first.match?(/\(.*?\)/) # (xxxxxx)
        next if bigram.split.first.include?('https://wame')

        next if bigram.split.last.start_with?('http', 'https', 'www', 'whatsapp:')
        next if bigram.split.last.match?(/\A\d+\z/) # Checks if the word is a number
        next if bigram.split.last.match?(/\A\d+\W+\d+\z/) # Checks if the word is a number
        next if bigram.split.last.match?(/\(.*?\)/) # (xxxxxx)
        next if bigram.split.last.include?('https://wame')

        word_occurrences[bigram] += 1
      end
    end

    word_occurrences.select { |_bigram, count| count > 1 }
                    .sort_by { |_k, v| v }
                    .reverse
                    .take(limit)
  end

  def save_image(url)
    # return if image.attached?

    begin
      filename = File.basename(URI.parse(url).path)
      image.attach(io: URI.open(url), filename:) # rubocop:disable Security/Open
    rescue StandardError => e
      filename = 'placeholder.jpg'
      image.attach(io: URI.open('https://placehold.co/500x500/000000/FFFFFF/jpg'), filename:) # rubocop:disable Security/Open
      puts "#{e.message} - #{url}"
    end
  end

  def update_total_count
    update!(total_count: likes_count + comments_count)
  end

  def collabs; end
end
