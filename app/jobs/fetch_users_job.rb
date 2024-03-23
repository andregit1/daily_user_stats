class FetchUsersJob < ApplicationJob
  # will run every hour
  queue_as :default
  
  def perform(*args)
    # Fetch user records from the API
    conn = Faraday.new(url: 'https://randomuser.me')
    response = conn.get('/api/', { results: 20 })
    records = JSON.parse(response.body)['results']
    
    # Update the total counts of male and female records in Redis
    update_redis_counts(records)
  end
  
  private
  
  def update_redis_counts(records)
    male_count = records.count { |record| record['gender'] == 'male' }
    female_count = records.count { |record| record['gender'] == 'female' }
    
    user_stats_key = 'user_stats'
    
    $redis.multi do
      $redis.hset(user_stats_key, 'male_count', male_count)
      $redis.hset(user_stats_key, 'female_count', female_count)
    end
  end
end
