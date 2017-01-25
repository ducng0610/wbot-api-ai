# frozen_string_literal: true
class MessageDigestor
  class << self
    def digest(message)
      if message.quick_replies.present?
        quick_replies = message.quick_replies.map { |qr| { title: qr.title, content_type: qr.content_type, payload: qr.payload } }
      end

      if /FACEBOOK_TEMPLATE_LIST/ === message.body
        return JSON.parse(message.body.slice('FACEBOOK_TEMPLATE_LIST:'))
      else
        return {
          text: message.body,
          quick_replies: quick_replies ? quick_replies : nil
        }
      end
    end
  end
end