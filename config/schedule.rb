# frozen_string_literal: true

set :environment, 'production'

every '5 0,4,8,12,16,20 * * *' do
  rake 'instagram:update_news_posts'
end

every '0 1,9,17 * * *' do
  rake 'instagram:update_posts'
end

every '0 4,16 * * *' do
  rake 'instagram:update_profiles_stats'
end

every '30 0 * * *' do
  rake 'instagram:update_profiles'
end

every '0 5 * * *' do
  rake 'util:collaborations'
end

every '30 5 * * *' do
  rake 'util:add_mentions_profiles'
end

every '0 2 * * *' do
  rake 'instagram:create_daily_stats'
end

every '20 2 * * *' do
  rake 'tiktok:update_posts'
end
