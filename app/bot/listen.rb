# frozen_string_literal: true
# app/bot/listen.rb

require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

# message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
# message.sender      # => { 'id' => '1008372609250235' }
# message.sent_at     # => 2016-04-22 21:30:36 +0200
# message.text        # => 'Hello, bot!'

Bot.on :message do |message|
  puts "[debuz] got from Facebook... #{message.text}"
  wit_response_message = ChatExtension.response(message.text, message.sender['id'])
  reponse_message = MessageDigestor.digest(wit_response_message)

  Bot.deliver({
                recipient: message.sender,
                message: reponse_message
              }, access_token: ENV['ACCESS_TOKEN'])
end
