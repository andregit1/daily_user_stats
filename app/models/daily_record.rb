class DailyRecord < ApplicationRecord
  # Calculates the average age of male and female users
  before_save :calculate_average_age
  
  # Returns the current date in the specified format
  def self.current_date
    Date.today.strftime("%B %d, %Y")
  end

  # Stores the male and female counts in the DailyRecord table
  def self.store(redis_male_count, redis_female_count)
    daily_record = find_or_initialize_by(date: current_date)  
    daily_record.male_count = daily_record.male_count_was.to_i + redis_male_count.to_i
    daily_record.female_count = daily_record.female_count_was.to_i + redis_female_count.to_i
    daily_record.save
  end
  

  # Updates the male and female counts after user deletion
  def self.update_stats_after_user_deletion(user)
    daily_record = find_by(date: current_date)
    
    if daily_record&.persisted?
      if user.gender == 'male'
        daily_record.decrement(:male_count)
      elsif user.gender == 'female'
        daily_record.decrement(:female_count)
      end
  
      daily_record.save
    end
  end

  private

  # Calculates the average age based on male and female counts
  def calculate_average_age
    total_male_age = User.where(gender: 'male').sum(:age)
    total_female_age = User.where(gender: 'female').sum(:age)

    self.male_avg_age = total_male_age.to_f / self.male_count if self.male_count.positive?
    self.female_avg_age = total_female_age.to_f / self.female_count if self.female_count.positive?
  end
end
