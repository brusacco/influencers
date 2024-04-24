# frozen_string_literal: true

set :environment, 'production'

every 1.hour do
  rake 'instagram:update_news_posts'
end

every 6.hours do
  rake 'instagram:update_posts'
end

every 12.hours do
  rake 'instagram:update_profiles_stats'
end

every 24.hours do
  rake 'instagram:update_profiles'
end
