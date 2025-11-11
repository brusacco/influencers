class AddCompoundIndexesToProfiles < ActiveRecord::Migration[7.0]
  def change
    # Compound index for enabled + country queries
    # Optimizes: Profile.enabled.paraguayos
    add_index :profiles, [:enabled, :country_string],
              name: 'index_profiles_on_enabled_and_country',
              comment: 'Optimizes queries for enabled profiles by country'
    
    # Compound index for enabled + country + followers (for ORDER BY)
    # Optimizes: Profile.enabled.paraguayos.order(followers: :desc)
    add_index :profiles, [:enabled, :country_string, :followers],
              name: 'index_profiles_on_enabled_country_followers',
              comment: 'Optimizes queries for enabled profiles by country ordered by followers'
    
    # Compound index for enabled + country + profile_type
    # Optimizes: Profile.marcas, Profile.medios (enabled paraguayan profiles by type)
    add_index :profiles, [:enabled, :country_string, :profile_type],
              name: 'index_profiles_on_enabled_country_type',
              comment: 'Optimizes queries for enabled profiles by country and type'
    
    # Compound index for enabled + country + profile_type + followers
    # Optimizes: Profile.marcas.order(followers: :desc)
    add_index :profiles, [:enabled, :country_string, :profile_type, :followers],
              name: 'index_profiles_on_enabled_country_type_followers',
              comment: 'Optimizes queries for enabled profiles by country, type, and followers ordering'
    
    # Compound index for followers range queries with country
    # Optimizes: Profile.paraguayos.where(followers: 50_000..)
    add_index :profiles, [:country_string, :followers],
              name: 'index_profiles_on_country_and_followers',
              comment: 'Optimizes queries filtering by country and followers range'
  end
end
