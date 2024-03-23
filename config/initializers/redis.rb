$redis = Redis.new(url: Rails.configuration.redis_url, db: Rails.configuration.redis_db)
