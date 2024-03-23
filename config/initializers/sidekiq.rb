require 'sidekiq'
require 'sidekiq-cron'

# frozen_string_literal: true
sidekiq_config = { url: "#{Rails.configuration.redis_url}/#{Rails.configuration.redis_db}" }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path('config/sidekiq_schedule.yml', Rails.root))
    Sidekiq::Cron::Job.load_from_hash(Sidekiq.schedule)
  end
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
