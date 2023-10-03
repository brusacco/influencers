# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :set_profile, only: %i[show]

  def index
    @profiles = Profile.order(followers: :desc).limit(80)
  end

  def show
    @profiles = Profile.where.not(id: @profile.id).order(followers: :desc).limit(12)
    @posts = @profile.instagram_posts.order(posted_at: :desc).limit(12)

    @related_brands = Profile.where(username: @profile.related_brands)

    @engagement_rate = (@profile.total_interactions_count / Float(@profile.followers) * 100).round
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end
end
