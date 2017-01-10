class WeatherExtension
  class << self
    KEYREF = ' 781CF461BB6606AD814EFA58445F9F5F5B033976558B4904'

    def search_2hour_nowcast(location)
      dataset = '2hr_nowcast'
      forecast_raw_data = search(dataset)
      forecast_data_needed = forecast_raw_data['channel']['item']['weatherForecast']['area'].select{ |ae| ae['name'] == location }.first
      if forecast_data_needed.present?
        get_forecast_meaning(forecast_data_needed['forecast'])
      else
        '/not found/'
      end
    end

    private

    def search(dataset)
      url = get_url(dataset)

      RestClient.get(url) { |response, request, result|
        if response.code == 200
          return Hash.from_xml(response.body).as_json
        else
          puts "[debuz] got external API error: #{response.body}"
        end
      }
    end

    def get_url(dataset)
      "http://api.nea.gov.sg/api/WebAPI/?dataset=" + dataset + "&keyref=" + KEYREF
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


