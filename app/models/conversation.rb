# frozen_string_literal: true
class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uid, type: String
  field :context, type: Hash

  has_many :messages
end
