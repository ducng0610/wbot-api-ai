# frozen_string_literal: true
class AbbreviationExtension
  class << self
    def encode_region(location)
      case location.downcase
      when 'national reporting stations'
        'NRS'
      when /north/
        'rNO'
      when /south/
        'rSO'
      when /central/, /center/, /centre/
        'rCE'
      when /west/
        'rWE'
      when /east/
        'rEA'
      else
        ''
      end
    end

    def encode_region_24HoursForecast(location)
      case location.downcase
      when /north/
        'wxnorth'
      when /south/
        'wxsouth'
      when /central/, /center/, /centre/
        'wxcentral'
      when /west/
        'wxwest'
      when /east/
        'wxeast'
      else
        ''
      end
    end

    def decode_region_24HoursForecast(location)
      location[2, 5].capitalize
    end

    def get_forecast_meaning(abbreviation)
      weather_abbreviation = {
        'BR' => 'Mist',
        'CL' => 'Cloudy',
        'DR' => 'Drizzle',
        'FA' => 'Fair (Day)',
        'FG' => 'Fog',
        'FN' => 'Fair (Night)',
        'FW' => 'Fair & Warm',
        'HG' => 'Heavy Thundery Showers with Gusty Winds',
        'HR' => 'Heavy Rain',
        'HS' => 'Heavy Showers',
        'HT' => 'Heavy Thundery Showers',
        'HZ' => 'Hazy',
        'LH' => 'Slightly Hazy',
        'LR' => 'Light Rain',
        'LS' => 'Light Showers',
        'OC' => 'Overcast',
        'PC' => 'Partly Cloudy (Day)',
        'PN' => 'Partly Cloudy (Night)',
        'PS' => 'Passing Showers',
        'RA' => 'Moderate Rain',
        'SH' => 'Showers',
        'SK' => 'Strong Winds, Showers',
        'SN' => 'Snow',
        'SR' => 'Strong Winds, Rain',
        'SS' => 'Snow Showers',
        'SU' => 'Sunny',
        'SW' => 'Strong Winds',
        'TL' => 'Thundery Showers',
        'WC' => 'Windy, Cloudy',
        'WD' => 'Windy',
        'WF' => 'Windy, Fair',
        'WR' => 'Windy, Rain',
        'WS' => 'Windy, Showers'
      }
      weather_abbreviation[abbreviation]
    end
  end
end
