# frozen_string_literal: true

class PostController < ApplicationController
  def index
    @posts = InstagramPost.a_week_ago.order(total_count: :desc).limit(20)
    @videos = InstagramPost.a_week_ago.order(video_view_count: :desc).limit(20)
    @comments = InstagramPost.a_week_ago.order(comments_count: :desc).limit(20)
  end
end
