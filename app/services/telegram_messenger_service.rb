# frozen_string_literal: true
# Telegram platform only
require 'telegram/bot'

class TelegramMessengerService
  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
  end

  def process
    request_message = @message
    uid = @user.uid

    # Record
    DashbotIntegrationService.incoming(request_message, uid)
    Message.create(body: request_message, user: @user, kind: 'incoming')

    if request_message.start_with? '/'
      handle_command(request_message)
    else
      unless request_message.nil?
        puts "[debuz] got from Telegram... #{request_message}"
        chat_service = ChatService.new(uid, 'telegram')
        chat_service.execute(request_message)
        send_message(chat_service.response_message, chat_service.quick_replies, chat_service.response_template)
        if chat_service.follow_up_response_message.present?
          send_message(chat_service.follow_up_response_message, chat_service.quick_replies)
        end
      end
    end
  end

  def deliver
    send_message(@message)
  end

  private

  def handle_command(request_message)
    case request_message
    when '/start'
      message = 'Hi, This is WeatherBot. How can I help you?'
      quick_replies = ['Current weather', '24-Hour Forecast', 'PSI']
    when '/stop'
      message = 'Sorry to see you go :('
    else
      message = 'Unknown command. :)'
    end

    send_message(message, quick_replies)
  end

  def send_message(message, quick_replies = nil, template = nil)
    uid = @user.uid

    if quick_replies.present?
      quick_replies.delete('location@#$')
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [quick_replies], one_time_keyboard: true)
    else
      markup = nil
    end

    if message
      parse_mode = nil
    else
      parse_mode = 'HTML'
      message = template
    end

    @api.call('sendMessage', chat_id: uid, text: message, reply_markup: markup, parse_mode: parse_mode)

    # Record
    DashbotIntegrationService.outgoing(message, uid)
    Message.create(body: message, user: @user, kind: 'outgoing')
  end
end
