class TabulateDailyRecordsJob < ApplicationJob
  # will run every end of day
  queue_as :default
  
  def perform(*args)
    # Retrieve the total number of male and female records captured within the day from Redis
    male_count = $redis.hget('user_stats', 'male_count').to_i
    female_count = $redis.hget('user_stats', 'female_count').to_i
    
    # Store the total counts into the DailyRecord table
    DailyRecord.store(male_count, female_count)
  end
end
