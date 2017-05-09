# frozen_string_literal: true
class FacebookMessengerService
  class << self
    def deliver(uid, message, quick_replies = nil, template = nil)
      puts "[debuz] sending '#{message}' to user '#{uid}'"

      Message.create(body: template.present? ? template : message, user: User.find_by(uid: uid), kind: 'outgoing')

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
        puts '[debuz] Cannot deliver message to facebook: ' + e.message
      end
    end
  end
end
