# frozen_string_literal: true
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uid, type: String
  field :email, type: String
  field :telegram_id, type: String
  field :first_name, type: String
  field :last_name, type: String

  has_many :messages

  validates_uniqueness_of :uid
  validates_uniqueness_of :telegram_id
end
