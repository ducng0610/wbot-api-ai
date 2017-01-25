# frozen_string_literal: true
class WeatherExtension
  class << self
    def search_forecast(location)
      dataset = '2hr_nowcast'
      forecast_raw_data = search(dataset)

      return nil if forecast_raw_data.nil?

      forecast_data_needed = forecast_raw_data['channel']['item']['weatherForecast']['area'].select { |ae| ae['name'].casecmp(location.downcase).zero? }.first
      if forecast_data_needed.present?
        AbbreviationExtension.get_forecast_meaning(forecast_data_needed['forecast'])
      end
    end

    def search_24HoursForecast(location)
      dataset = '24hrs_forecast'
      forecast_raw_data = search(dataset)

      return nil if forecast_raw_data.nil?

      location = AbbreviationExtension.encode_region_24HoursForecast(location)
      return nil if location.blank?

      elements = []
      elements << {
        title: '24 Hour Forecast',
        image_url: 'http://duhoctoancau.com/wp-content/uploads/2016/12/trung-tam-tu-van-du-hoc-singapore-3.jpg',
        subtitle: 'Meteorological Service Singapore',
        default_action: {
          type: 'web_url',
          url: 'https://robusttechhouse.com/',
          messenger_extensions: true,
          webview_height_ratio: 'tall',
          fallback_url: 'https://robusttechhouse.com/'
        }
      }

      (3..5).each do |index|
        forecast = forecast_raw_data['channel'].to_a[index][1]
        elements << {
          title: AbbreviationExtension.get_forecast_meaning(forecast[location]),
          image_url: 'https://robusttechhouse.com/wp-content/uploads/2016/02/RTH-Logo-transparent-background.png',
          subtitle: forecast['timePeriod'],
          default_action: {
            type: 'web_url',
            url: 'https://robusttechhouse.com/',
            messenger_extensions: true,
            webview_height_ratio: 'tall',
            fallback_url: 'https://robusttechhouse.com/'
          }
        }
      end

      response = {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'list',
            top_element_style: 'large',
            elements: elements
          }
        }
      }
      response.to_json
    end

    def search_hour_psi(location)
      dataset = 'pm2.5_update'
      forecast_raw_data = search(dataset)

      begin
        forecast_raw_data['channel']['item']['region'].select { |ae| ae['id'].casecmp(AbbreviationExtension.encode_region(location).downcase).zero? }.first['record']['reading']['value']
      rescue
      end
    end

    def search_day_psi(location)
      dataset = 'psi_update'
      forecast_raw_data = search(dataset)

      begin
        forecast_raw_data['channel']['item']['region'].select { |ae| ae['id'].casecmp(AbbreviationExtension.encode_region(location).downcase).zero? }.first['record']['reading'].select { |ae| ae['type'].casecmp('NPSI').zero? }.first['value']
      rescue
      end
    end

    private

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
  end
end
