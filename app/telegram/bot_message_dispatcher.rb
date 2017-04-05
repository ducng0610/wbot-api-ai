# Telegram platform only
require 'telegram/bot'

class BotMessageDispatcher
  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
  end

  def process
    request_message = @message[:message][:text]
    uid = @user.telegram_id

    if request_message.start_with? '/'
      unknown_command
    else
      unless request_message.nil?
        puts "[debuz] got from Telegram... #{request_message}"
        chat_service = ChatService.new(uid)
        chat_service.execute(request_message)
        send_message(chat_service.response_message)
        if chat_service.follow_up_response_message.present?
          send_message(chat_service.follow_up_response_message)
        end
      end
    end
  end

  private

  def unknown_command
    send_message('Unknown command.')
  end

  def send_message(text, options={})
    @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
  end
end