class AcpAddonController < ApplicationController
  before_action :authenticate_admin!

  def chat_histories
    @users = User.all
  end

  def chat_history
    @user = User.find(params[:uid])
  end

  def statistic
  end
end
