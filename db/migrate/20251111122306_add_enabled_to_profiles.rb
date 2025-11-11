class AddEnabledToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :enabled, :boolean, default: false, null: false
    
    # Set enabled = true for all paraguayan profiles (existing ones)
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE profiles 
          SET enabled = true 
          WHERE country_string = 'Paraguay'
        SQL
      end
    end
    
    # Add index for performance
    add_index :profiles, :enabled
  end
end
