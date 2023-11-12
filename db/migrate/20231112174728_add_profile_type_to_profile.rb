class AddProfileTypeToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :profile_type, :integer
  end
end
