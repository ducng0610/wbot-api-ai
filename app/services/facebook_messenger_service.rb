# frozen_string_literal: true
class FacebookMessengerService
  class << self
    def deliver(uid, message, quick_replies = nil, template = nil)
      puts "[debuz] sending '#{message}' to user '#{uid}'"

      if template
        message_content = JSON.parse(template)
      else
        if quick_replies.present?
          quick_replies = quick_replies.map { |qr| qr == 'location@#$' ? { content_type: 'location' } : { title: qr, content_type: 'text', payload: 'empty' } }
        end
        message_content = {
          text: message,
          quick_replies: quick_replies ? quick_replies : nil
        }
      end

      begin
        Bot.deliver(
          {
            recipient: {
              id: uid
            },
            message: message_content
          },
          access_token: ENV['ACCESS_TOKEN']
        )
      rescue => e
        puts '[debuz] ' + e.message
      end
    end
  end
end
