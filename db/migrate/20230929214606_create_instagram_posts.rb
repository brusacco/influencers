class CreateInstagramPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :instagram_posts do |t|
      t.text :data
      t.references :profile, null: false, foreign_key: true
      t.text :image
      t.string :shortcode

      t.timestamps
    end
    add_index :instagram_posts, :shortcode
  end
end
