class CreateInstagramCollaborations < ActiveRecord::Migration[7.0]
  def change
    create_table :instagram_collaborations do |t|
      t.integer :instagram_post_id
      t.integer :collaborator_id
      t.integer :collaborated_id
      t.datetime :posted_at

      t.timestamps
    end
    add_index :instagram_collaborations, :instagram_post_id
    add_index :instagram_collaborations, :collaborator_id
    add_index :instagram_collaborations, :collaborated_id
    add_index :instagram_collaborations, :posted_at
    add_index :instagram_collaborations, %i[instagram_post_id collaborator_id], name: 'index_ig_post_collab'
    add_index :instagram_collaborations, %i[collaborator_id posted_at], name: 'index_ig_collab_posted_at'
    add_index :instagram_collaborations, %i[collaborated_id posted_at], name: 'index_ig_collaborated_posted_at'
  end
end
