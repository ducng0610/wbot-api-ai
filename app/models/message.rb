class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :conversation_id, type: Integer
  field :kind, type: String

  belongs_to :conversation
  validates_inclusion_of :kind, in: %w(outgoing incoming), allow_nil: false
end
