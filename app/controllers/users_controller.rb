class UsersController < ApplicationController
  include Pagy::Backend

  before_action :find_user, only: [:destroy]
  
  def index
    @total_users = User.count
    @daily_records = DailyRecord.order(created_at: :desc).limit(20)
    @users = User.filters(filter_params)
    @pagy, @users = pagy(@users, items: 20)
  end
  
  def destroy
    @user.destroy
    DailyRecord.update_stats_after_user_deletion(@user)
    redirect_to action: :index, notice: "User #{@user.name[:first]} was successfully destroyed.", status: :see_other
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def filter_params
    params.fetch(:search, {}).permit(:name, :age, :gender, :created_at)
  end
end
