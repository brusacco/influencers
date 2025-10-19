class AddIndexToProfileTypeOnProfiles < ActiveRecord::Migration[7.0]
  def change
    add_index :profiles, :profile_type
  end
end
