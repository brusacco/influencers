# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = InstagramPost.a_day_ago.order(total_count: :desc).limit(20)
    @videos = InstagramPost.a_day_ago.order(video_view_count: :desc).limit(20)
    @likes = InstagramPost.a_day_ago.order(likes_count: :desc).limit(20)
    @comments = InstagramPost.a_day_ago.order(comments_count: :desc).limit(20)
  end

  def commented
    @posts = InstagramPost.a_week_ago.order(comments_count: :desc).limit(48)
  end

  def liked
    @posts = InstagramPost.a_week_ago.order(likes_count: :desc).limit(48)
  end

  def video_viewed
    @posts = InstagramPost.a_week_ago.order(video_view_count: :desc).limit(48)
  end
end
