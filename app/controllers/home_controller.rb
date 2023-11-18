# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!, except: :deploy
  skip_before_action :verify_authenticity_token

  def index; end

  def deploy
    Dir.chdir('/home/rails/influencers') do
      system('export RAILS_ENV=production')

      # Fix this issue
      system('git checkout -- Gemfile.lock')

      # Check out the latest code from the Git repository
      system('git pull')

      # Install dependencies
      system('bundle install')

      # Migrate the database
      system('RAILS_ENV=production rails db:migrate')

      # Precompile assets
      system('RAILS_ENV=production rake assets:precompile')

      # Restart the Puma server
      system('touch tmp/restart.txt')
    end

    render plain: 'Deployment complete!'
  end
end
