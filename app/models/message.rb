class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :user_id, type: String
  field :kind, type: String
  field :type, type: String

  belongs_to :user

  validates_inclusion_of :kind, :in => ["outgoing", "incoming"], allow_nil: false
end
