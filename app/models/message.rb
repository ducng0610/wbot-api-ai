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
end
