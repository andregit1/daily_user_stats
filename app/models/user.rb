class User < ApplicationRecord
  include LiquidNameable

  # Orders users by created_at in descending order by default
  default_scope { descending }
  scope :descending, -> { order(created_at: :desc) }

  # Filters users based on given parameters
  scope :filters, ->(params) do
    params ||= {}

    collection = descending

    collection = collection.where("LOWER(name ->> 'first') LIKE :name OR LOWER(name ->> 'last') LIKE :name", name: "%#{params[:name].downcase}%") if params[:name].present?
    collection = collection.where(age: params[:age]) if params[:age].present?
    collection = collection.where(gender: params[:gender]) if params[:gender].present?
    collection = collection.where("DATE(created_at) = :created_at", created_at: params[:created_at].to_date) if params[:created_at].present?

    collection.distinct
  end

  # Stores or updates user records from the provided array
  def self.store(records)
    records.each do |record|
      uuid = record['login']['uuid']
      gender = record['gender']
      name = record['name']
      location = record['location']
      age = record['dob']['age']

      user = find_or_initialize_by(uuid: uuid)
      user.assign_attributes(
        gender: gender,
        name: name,
        location: location,
        age: age
      )

      user.new_record? ? user.save : user.save(validate: false) # Save without validation if record already exists
    end
  end
end
