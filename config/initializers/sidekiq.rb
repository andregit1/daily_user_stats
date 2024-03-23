require 'sidekiq'
require 'sidekiq-cron'

# frozen_string_literal: true
sidekiq_config = { url: "#{Rails.configuration.redis_url}/#{Rails.configuration.redis_db}" }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'sidekiq_schedule.yml')
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
  end
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
