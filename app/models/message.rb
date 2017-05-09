class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :user_id, type: Integer
  field :kind, type: String
  field :type, type: String

  validates_inclusion_of :kind, :in => ["outgoing", "incoming"], allow_nil: false
end
