# frozen_string_literal: true
class QuickReply
  include Mongoid::Document
  field :title, type: String
  field :content_type, type: String
  field :payload, type: String

  belongs_to :message
end
