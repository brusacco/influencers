# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    # SEO Meta Tags - Homepage
    set_meta_tags(
      title: "#{SITE_NAME} - #{SITE_TAGLINE}",
      description: DESCRIPTION,
      keywords: KEYWORDS,
      canonical: root_url,
      og: {
        title: "#{SITE_NAME} - #{SITE_TAGLINE}",
        description: DESCRIPTION,
        type: 'website',
        url: root_url,
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "#{SITE_NAME} - #{SITE_TAGLINE}",
        description: DESCRIPTION,
        image: OG_IMAGE_URL
      },
      alternate: {
        'es-PY' => root_url
      }
    )
  end

  def deploy
    Dir.chdir('/home/rails/influencers') do
      system('export RAILS_ENV=production')

      # Fix this issue
      system('git checkout -- Gemfile.lock')

      # Check out the latest code from the Git repository
      system('git pull')

      # Install dependencies
      system('RAILS_ENV=production bundle install')

      # Migrate the database
      system('RAILS_ENV=production rails db:migrate')

      # Precompile assets
      system('RAILS_ENV=production rake assets:precompile')

      # Restart the Puma server
      # system('touch tmp/restart.txt')
      # Preferred: phased restart via pumactl (requires state_path + control app)
      system('RAILS_ENV=production bundle exec pumactl --state tmp/pids/puma.state phased-restart')
    end

    render plain: 'Deployment complete!'
  end
end
