# frozen_string_literal: true
class WeatherExtension
  class << self
    def search_forecast(location)
      dataset = '2hr_nowcast'
      forecast_raw_data = search(dataset)

      return nil if forecast_raw_data.nil?

      forecast_data_needed = forecast_raw_data['channel']['item']['weatherForecast']['area'].select { |ae| ae['name'].casecmp(location.downcase).zero? }.first
      if forecast_data_needed.present?
        get_forecast_meaning(forecast_data_needed['forecast'])
      end
    end

    def search_24HoursForecast(location)
      dataset = '24hrs_forecast'
      forecast_raw_data = search(dataset)

      return nil if forecast_raw_data.nil?

      location = encode_region_24HoursForecast(location)
      return nil if location.blank?

      forecast_data = []
      (3..5).each do |index|
        forecast = forecast_raw_data['channel'].to_a[index][1]
        forecast_data << "#{get_forecast_meaning(forecast[location])} from #{forecast['timePeriod']}"
      end

      forecast_data.join('. ')
    end

    def search_hour_psi(location)
      dataset = 'pm2.5_update'
      forecast_raw_data = search(dataset)

      begin
        forecast_raw_data['channel']['item']['region'].select { |ae| ae['id'].casecmp(encode_region(location).downcase).zero? }.first['record']['reading']['value']
      rescue
      end
    end

    def search_day_psi(location)
      dataset = 'psi_update'
      forecast_raw_data = search(dataset)

      begin
        forecast_raw_data['channel']['item']['region'].select { |ae| ae['id'].casecmp(encode_region(location).downcase).zero? }.first['record']['reading'].select { |ae| ae['type'].casecmp('NPSI').zero? }.first['value']
      rescue
      end
    end

    private

    def encode_region(location)
      case location.downcase
      when 'national reporting stations'
        'NRS'
      when /north/
        'rNO'
      when /south/
        'rSO'
      when /central/, /center/
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
      when /central/, /center/
        'wxcentral'
      when /west/
        'wxwest'
      when /east/
        'wxeast'
      else
        ''
      end
    end

    def search(dataset)
      url = get_url(dataset)

      RestClient.get(url) do |response, _request, _result|
        if response.code == 200
          puts "[debuz] restclient: got #{response.body} ..."
          return Hash.from_xml(response.body).as_json
        else
          puts "[debuz] got external API error: #{response.body}"
        end
      end
    end

    def get_url(dataset)
      'http://api.nea.gov.sg/api/WebAPI/?dataset=' + dataset + '&keyref=' + ENV['WEATHER_API_KEYREF']
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
