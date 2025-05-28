class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user, only: [:show]

  def show
    @user = User.find(params[:id])
    @events = @user.events
  end

  private
  
  def check_user
    unless current_user.id == params[:id].to_i
      flash[:alert] = "Vous n'avez pas accès à cette page"
      redirect_to root_path
    end
  end
end
