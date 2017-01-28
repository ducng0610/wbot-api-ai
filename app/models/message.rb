# frozen_string_literal: true
class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :conversation_id, type: Integer
  field :kind, type: String

  has_many :quick_replies
  belongs_to :conversation

  validates_inclusion_of :kind, in: %w(outgoing incoming), allow_nil: false
  validates :conversation, presence: true

  def digest
    if quick_replies.present?
      quick_replies = self.quick_replies.map { |qr| { title: qr.title, content_type: qr.content_type, payload: qr.payload } }
    end

    if /FACEBOOK_TEMPLATE_LIST/ === body
      body = self.body
      body.slice!('FACEBOOK_TEMPLATE_LIST:')
      reponse_message = JSON.parse(body)
    else
      reponse_message = {
        text: self.body,
        quick_replies: quick_replies ? quick_replies : nil
      }
    end

    deliver(reponse_message, conversation.uid)
  end

  private

  def deliver(reponse_message, uid)
    Bot.deliver(
      {
        recipient: {
          id: uid
        },
        message: reponse_message
      },
      access_token: ENV['ACCESS_TOKEN']
    )
  end
end
