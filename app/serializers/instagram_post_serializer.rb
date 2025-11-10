# frozen_string_literal: true

class InstagramPostSerializer
  attr_reader :post

  def initialize(post)
    @post = post
  end

  def as_json
    {
      id: post.id,
      shortcode: post.shortcode,
      url: post.url,
      caption: post.caption,
      media: post.media,
      product_type: post.product_type,
      posted_at: post.posted_at,
      likes_count: post.likes_count,
      comments_count: post.comments_count,
      video_view_count: post.video_view_count,
      total_count: post.total_count,
      profile_id: post.profile_id,
      created_at: post.created_at,
      updated_at: post.updated_at
    }
  end

  # Serialización con información del perfil incluida
  def as_json_with_profile
    as_json.merge(
      profile: {
        id: post.profile.id,
        username: post.profile.username,
        full_name: post.profile.full_name,
        profile_pic_url: post.profile.profile_pic_url
      }
    )
  end

  # Método de clase para serializar una colección
  def self.collection(posts, include_profile: false)
    posts.map do |post|
      serializer = new(post)
      include_profile ? serializer.as_json_with_profile : serializer.as_json
    end
  end
end

