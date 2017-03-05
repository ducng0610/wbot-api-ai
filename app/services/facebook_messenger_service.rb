# frozen_string_literal: true
class FacebookMessengerService
  class << self
    def deliver(message, quick_replies = nil, uid)
      puts "[debuz] sending '#{message}' to user '#{uid}'"

      if quick_replies.present?
        quick_replies = quick_replies.map { |qr| qr == 'location@#$' ? { content_type: 'location' } : { title: qr, content_type: 'text', payload: 'empty' } }
      end

      begin
        Bot.deliver(
          {
            recipient: {
              id: uid
            },
            message: {
              text: message,
              quick_replies: quick_replies ? quick_replies : nil
            }
          },
          access_token: ENV['ACCESS_TOKEN']
        )
      rescue => e
        puts '[debuz] ' + e.message
      end
    end
  end
end
