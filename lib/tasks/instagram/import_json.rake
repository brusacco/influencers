# frozen_string_literal: true

namespace :instagram do
  desc 'Import JSON'
  task import_json: :environment do
    url = 'http://admin.moopio.com:5000/main/export'
    response = HTTParty.get(url)
    data = JSON.parse(response.body)
    data.each do |profile|
      Profile.find_or_create_by!(username: profile['username']) do |new_profile|
        puts new_profile.username
      end
    end
  end
end
