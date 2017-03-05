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

  # def self.get_known_location(location, type)
  #   return nil if location.blank?
  #   location.gsub!('psi', '') # Quick fix for wit/location taking 'psi' as location name

  #   location = location.downcase
  #   known_location = KnownLocation.where(type: type).only(:name).pluck(:name).select { |name| location.include? name }.first

  #   if known_location.present?
  #     return known_location.capitalize
  #   else
  #     return nil
  #   end
  # end

  # def self.guess_known_location(location, type)
  #   return nil if location.blank?
  #   location.gsub!('psi', '') # Quick fix for wit/location taking 'psi' as location name

  #   jarow = FuzzyStringMatch::JaroWinkler.create(:native)

  #   location = location.downcase
  #   known_locations = KnownLocation.where(type: type).only(:name).pluck(:name)
  #   known_locations_with_distance = {}
  #   known_locations.each do |known_location|
  #     known_locations_with_distance[known_location] = jarow.getDistance(known_location, location)
  #   end

  #   known_location = known_locations_with_distance.max_by { |_name, distance| distance }
  #   if known_location[1] < 0.7
  #     return nil
  #   else
  #     return known_location[0].capitalize
  #   end
  # end

  def self.guess_known_location_by_coordinates(coordinates)
    known_location = KnownLocation.where(type: 'location').min_by { |loc| distance(coordinates, [loc.lat, loc.lon]) }
    known_location.name
  end

  private

  # Distance between two coordinates on earth calculated using Haversine formula
  # distance [46.3625, 15.114444],[46.055556, 14.508333]
  # => 57794.35510874037
  def self.distance(loc1, loc2)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map { |i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c # Delta in meters
  end
end
