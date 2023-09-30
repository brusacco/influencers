class AddDataToInstagramPost < ActiveRecord::Migration[7.0]
  def change
    add_column :instagram_posts, :likes_count, :integer, default: 0
    add_column :instagram_posts, :comments_count, :integer, default: 0
    add_column :instagram_posts, :video_view_count, :integer, default: 0
    add_column :instagram_posts, :product_type, :string
    add_index :instagram_posts, :product_type
    add_column :instagram_posts, :media, :string
    add_index :instagram_posts, :media
    add_column :instagram_posts, :caption, :text
    add_column :instagram_posts, :url, :string
    add_column :instagram_posts, :posted_at, :datetime
  end
end
