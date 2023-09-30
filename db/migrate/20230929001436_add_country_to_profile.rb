class AddCountryToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :country_string, :string
    add_index :profiles, :country_string
  end
end
