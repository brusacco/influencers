# frozen_string_literal: true

set :environment, 'production'

every 6.hour do
  rake 'instagram:update_news_posts'
end

every 12.hours do
  rake 'instagram:update_profiles_stats'
end

every 24.hours do
  rake 'instagram:update_posts'
  rake 'instagram:update_profiles'
  rake 'util:collaborations'
  rake 'util:add_mentions_profiles'
end
