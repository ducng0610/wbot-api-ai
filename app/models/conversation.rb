class Conversation
  include Mongoid::Document
  field :uid, type: String
  field :context, type: Hash

  before_create :set_uid
  has_many :messages

  private

  def set_uid
    return if uid.present?
    self.uid = generate_uid
  end

  def generate_uid
    SecureRandom.uuid.delete('-')
  end
end
