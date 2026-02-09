require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sqily
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Bern"

    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}").to_s]
    config.i18n.available_locales = ["fr-CH", "de-CH", "it-CH", "en"]
    config.i18n.default_locale = "fr-CH"

    config.assets.precompile += %w[tree.js trix.js trix.css layout.css]
    config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif *.otf *.eot *.svg *.ttf *.woff *.swf]
    config.assets.paths << Rails.root + "/vendor/assets"

    # Fix for Tolk: Psych::DisallowedClass: Tried to load unspecified class: Symbol
    # config.active_record.yaml_column_permitted_classes = [Symbol, ActiveSupport::HashWithIndifferentAccess]
  end

  def self.latest_commit_id
    @latest_commit_id ||= `git rev-parse HEAD`.strip
  end
end
