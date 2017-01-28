# frozen_string_literal: true
require 'fuzzystringmatch'

class KnownLocation
  include Mongoid::Document
  before_save :name_downcase

  field :name, type: String
  field :type, type: String
  field :lat, type: Float
  field :lon, type: Float

  validates_uniqueness_of :name

  def name_downcase
    self.name = name.downcase
  end

  def self.get_known_location(location, type)
    return nil if location.blank?

    regex_str = Regexp.new(location.downcase)
    known_location = KnownLocation.where(name: regex_str, type: type).first
    if known_location.present?
      return known_location.name.capitalize
    else
      return nil
    end
  end

  def self.guess_known_location(location, type)
    return nil if location.blank?

    jarow = FuzzyStringMatch::JaroWinkler.create(:native)

    location = location.downcase
    known_locations = KnownLocation.where(type: type).only(:name).pluck(:name)
    known_locations_with_distance = {}
    known_locations.each do |known_location|
      known_locations_with_distance[known_location] = jarow.getDistance(known_location, location)
    end

    known_location = known_locations_with_distance.max_by { |_name, distance| distance }
    if known_location[1] < 0.7
      return nil
    else
      return known_location[0].capitalize
    end
  end
end
