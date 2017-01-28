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
    location.gsub!('psi', '') # Quick fix for wit/location taking 'psi' as location name

    location = location.downcase
    known_location = KnownLocation.where(type: type).only(:name).pluck(:name).select { |name| location.include? name }.first

    if known_location.present?
      return known_location.capitalize
    else
      return nil
    end
  end

  def self.guess_known_location(location, type)
    return nil if location.blank?
    location.gsub!('psi', '') # Quick fix for wit/location taking 'psi' as location name

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
