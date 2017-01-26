# frozen_string_literal: true
class MessageDigestor
  class << self
    def digest(message, uid)
      if message.quick_replies.present?
        quick_replies = message.quick_replies.map { |qr| { title: qr.title, content_type: qr.content_type, payload: qr.payload } }
      end

      if /FACEBOOK_TEMPLATE_LIST/ === message.body
        body = message.body
        body.slice!('FACEBOOK_TEMPLATE_LIST:')
        reponse_message = JSON.parse(body)
      else
        reponse_message = {
          text: message.body,
          quick_replies: quick_replies ? quick_replies : nil
        }
      end

      deliver(reponse_message, uid)
    end

    private

    def deliver(reponse_message, uid)
      Bot.deliver({
                    recipient: {
                      id: uid
                    },
                    message: reponse_message
                  }, access_token: ENV['ACCESS_TOKEN'])
    end
  end
end
