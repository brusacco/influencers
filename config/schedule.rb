# frozen_string_literal: true

set :environment, 'production'

every 6.hours do
  rake 'instagram:test'
  rake 'instagram:update_profiles_stats'
end
