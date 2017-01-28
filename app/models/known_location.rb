class KnownLocation
  include Mongoid::Document
  field :name, type: String
  field :type, type: String
  field :lat, type: Float
  field :lon, type: Float

  validates_uniqueness_of :name

  def self.known_region?(location)
  end

  def self.known_location?(location)
  end
end
