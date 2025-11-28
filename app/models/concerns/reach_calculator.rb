# frozen_string_literal: true

# Concern to calculate estimated reach for influencer profiles
# Uses hybrid method combining follower-based and interaction-based calculations
module ReachCalculator
  extend ActiveSupport::Concern

  # Constants for reach calculation
  ENGAGEMENT_RATE = 0.15
  INTERACTION_TO_REACH_MULTIPLIER = 10
  FOLLOWER_WEIGHT = 0.6
  INTERACTION_WEIGHT = 0.4
  MAX_REACH_PERCENTAGE = 0.5

  # Calculate estimated reach using hybrid method
  # Combines follower-based and interaction-based calculations
  # @param total_interactions [Integer] Total interactions (likes + comments + shares)
  # @param total_posts [Integer] Total number of posts in the period
  # @return [Integer] Estimated reach (unique accounts reached)
  def calculate_estimated_reach(total_interactions:, total_posts:)
    return 0 if followers.zero? || total_posts.zero?

    # Método 1: Basado en followers (engagement promedio)
    follower_based_reach = followers * ENGAGEMENT_RATE

    # Método 2: Basado en interacciones (asumiendo que 10% de interacciones = reach)
    interaction_based_reach = total_interactions * INTERACTION_TO_REACH_MULTIPLIER

    # Promedio ponderado (60% followers, 40% interactions)
    weighted_reach = (follower_based_reach * FOLLOWER_WEIGHT) + 
                    (interaction_based_reach * INTERACTION_WEIGHT)

    # Cap máximo: nunca más del 50% de followers
    max_reach = followers * MAX_REACH_PERCENTAGE

    [weighted_reach, max_reach].min.round
  end

  # Calculate estimated reach as percentage of followers
  # @param total_interactions [Integer] Total interactions
  # @param total_posts [Integer] Total number of posts
  # @return [Float] Reach percentage (0-100)
  def calculate_estimated_reach_percentage(total_interactions:, total_posts:)
    return 0.0 if followers.zero?

    reach = calculate_estimated_reach(
      total_interactions: total_interactions,
      total_posts: total_posts
    )
    (reach.to_f / followers * 100).round(2)
  end
end

