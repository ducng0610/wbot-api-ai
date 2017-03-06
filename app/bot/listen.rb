# frozen_string_literal: true
# app/bot/listen.rb

require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

Bot.on :message do |message|
  # message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  # message.sender      # => { 'id' => '1008372609250235' }
  # message.sent_at     # => 2016-04-22 21:30:36 +0200
  # message.text        # => 'Hello, bot!'

  request_message = message.text
  uid = message.sender['id']
  User.create(uid: uid)

  # handle `share location` facebook message
  if request_message.nil?
    begin
      request_message = KnownLocation.guess_known_location_by_coordinates(message.attachments.first['payload']['coordinates'].values)
      if request_message.nil?
        FacebookMessengerService.deliver(uid, 'Sorry, currently I can only support Singapore locations.')
      end
    rescue => e
      puts '[debuz] got unhandlable facebook message: ' + e.message + ' :@: ' + message.to_json
    end
  end

  unless request_message.nil?
    puts "[debuz] got from Facebook... #{message.text}"
    chat_service = ChatService.new(uid)
    chat_service.execute(request_message)
    FacebookMessengerService.deliver(uid, chat_service.response_message, chat_service.quick_replies, chat_service.response_template)
  end
end

Bot.on :postback do |postback|
  # postback.sender    # => { 'id' => '1008372609250235' }
  # postback.recipient # => { 'id' => '2015573629214912' }
  # postback.sent_at   # => 2016-04-22 21:30:36 +0200
  # postback.payload   # => 'EXTERMINATE'

  if postback.payload == 'DEVELOPER_DEFINED_PAYLOAD_FOR_HELP'
    puts "[debuz] Human #{postback.recipient} marked for extermination"

    uid = postback.sender['id']
    message = 'I can tell you the (1) Current Weather (2) 24-Hour Forecast (3) PSI in different locations in Singapore. For example, you can ask me "What is the weather in Changi?"; "Is it raining in Bedok?"; "What is the forecast in the South?" or "What is the PSI in the North?"'
    quick_replies = ['Current weather', '24-Hour Forecast', 'PSI']
    FacebookMessengerService.deliver(uid, message, quick_replies)
  end
end
