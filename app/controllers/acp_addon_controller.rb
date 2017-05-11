class AcpAddonController < ApplicationController
  before_action :authenticate_admin!
  before_action :get_user, only: [:chat_history, :send_message]

  def chat_histories
    @users = User.all
  end

  def chat_history
  end

  # POST
  def send_message
    message = params[:message]

    case @user.source
    when 'facebook'
      FacebookMessengerService.deliver(@user.uid, message)
    when 'telegram'
      TelegramMessengerService.new(message, @user).deliver
    end

    redirect_to "/acp_addon/chat_history/#{params[:id]}"
  end

  def statistic
  end

  private

  def get_user
    @user = User.find(params[:id])
  end
end
