# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Influencers
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Add Rack::Deflater middleware
    config.middleware.use Rack::Deflater,
                          include: %w[
                            text/html
                            application/json
                            text/css
                            application/javascript
                            application/xml
                            text/plain
                            image/svg+xml
                          ]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Use dynamic error pages instead of static HTML
    config.exceptions_app = routes
  end
end
