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
      quick_replies = self.quick_replies.map { |qr| qr.title == 'Location' ? { content_type: 'location' } : { title: qr.title, content_type: qr.content_type, payload: qr.payload } }
    end

    if /FACEBOOK_TEMPLATE_LIST/ === body
      body = self.body
      body.slice!('FACEBOOK_TEMPLATE_LIST:')
      response_message = JSON.parse(body)
    else
      response_message = {
        text: self.body,
        quick_replies: quick_replies ? quick_replies : nil
      }
    end

    deliver(response_message, conversation.uid)
  end

  private

  def deliver(response_message, uid)
    # begin
    #   Bot.deliver(
    #     {
    #       recipient: {
    #         id: uid
    #       },
    #       message: response_message
    #     },
    #     access_token: ENV['ACCESS_TOKEN']
    #   )
    # rescue => e
    #   puts '[debuz] ' + e.message
    # end
  end
end
