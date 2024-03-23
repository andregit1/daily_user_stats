class DailyRecord < ApplicationRecord
  # Calculates the average age of male and female users
  before_save :calculate_average_age, if: -> { saved_change_to_male_count? || saved_change_to_female_count? }
  
  # Returns the current date in the specified format
  def self.current_date
    Date.today.strftime("%B %d, %Y")
  end

  # Stores the male and female counts in the DailyRecord table
  def self.store(male_count, female_count)
    daily_record = find_or_initialize_by(date: current_date)
    daily_record.assign_attributes(male_count: male_count, female_count: female_count)
    daily_record.save
  end

  # Updates the male and female counts after user deletion
  def self.update_stats_after_user_deletion(user)
    if user.gender == 'male'
      decrement(:male_count)
    elsif user.gender == 'female'
      decrement(:female_count)
    end

    daily_record = find_by(date: current_date)
    daily_record.save if daily_record&.persisted? && daily_record.saved_changes?
  end
  
  # Calculates the average age based on male and female counts
  def calculate_average_age
    total_male_count = male_count || 0
    total_female_count = female_count || 0

    total_male_age = User.where(gender: 'male').sum(:age)
    total_female_age = User.where(gender: 'female').sum(:age)

    self.male_avg_age = total_male_age.to_f / total_male_count if total_male_count.positive?
    self.female_avg_age = total_female_age.to_f / total_female_count if total_female_count.positive?
  end
end
