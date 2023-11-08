# frozen_string_literal: true

set :environment, 'production'

every 3.hours do
  rake 'instagram:crawler_top'
  rake 'instagram:update_profiles_stats'
end

every 6.hours do
  rake 'instagram:test'
  rake 'instagram:update_profiles_stats'
end
