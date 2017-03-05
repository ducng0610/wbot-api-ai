# frozen_string_literal: true
class WeatherService
  class << self
    def search_forecast(location)
      dataset = '2hr_nowcast'
      forecast_raw_data = search(dataset)
      return external_api_error if forecast_raw_data.nil?

      forecast_data_needed = forecast_raw_data['channel']['item']['weatherForecast']['area'].select { |ae| ae['name'].casecmp(location.downcase).zero? }.first
      if forecast_data_needed.present?
        forecast = AbbreviationService.get_forecast_meaning(forecast_data_needed['forecast'])
        "The weather in #{location} is going to be #{forecast}"
      else
        no_data_found
      end
    end

    def search_24HoursForecast(region)
      region = AbbreviationService.encode_region_24HoursForecast(region)
      return no_data_found if region.blank?

      dataset = '24hrs_forecast'
      forecast_raw_data = search(dataset)
      return external_api_error if forecast_raw_data.nil?

      elements = []
      elements << {
        title: "24 Hour Forecast (#{AbbreviationService.decode_region_24HoursForecast(region)} Region)",
        image_url: 'http://duhoctoancau.com/wp-content/uploads/2016/12/trung-tam-tu-van-du-hoc-singapore-3.jpg',
        subtitle: 'Meteorological Service Singapore',
        default_action: {
          type: 'web_url',
          url: 'https://robusttechhouse.com/',
          messenger_Services: true,
          webview_height_ratio: 'tall',
          fallback_url: 'https://robusttechhouse.com/'
        }
      }

      (3..5).each do |index|
        forecast = forecast_raw_data['channel'].to_a[index][1]
        elements << {
          title: AbbreviationService.get_forecast_meaning(forecast[region]),
          subtitle: forecast['timePeriod']
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

    def search_psi(region)
      hour_dataset = 'pm2.5_update'
      hour_forecast_raw_data = search(hour_dataset)
      day_dataset = 'psi_update'
      day_forecast_raw_data = search(day_dataset)
      return external_api_error if hour_forecast_raw_data.nil? || day_forecast_raw_data.nil?

      begin
        hour_psi = hour_forecast_raw_data['channel']['item']['region'].select { |ae| ae['id'].casecmp(AbbreviationService.encode_region(region).downcase).zero? }.first['record']['reading']['value']
        day_psi = day_forecast_raw_data['channel']['item']['region'].select { |ae| ae['id'].casecmp(AbbreviationService.encode_region(region).downcase).zero? }.first['record']['reading'].select { |ae| ae['type'].casecmp('NPSI').zero? }.first['value']
        "The hourly PM2.5 in the #{region} region is #{hour_psi} and the 24 hour PSI is #{day_psi}"
      rescue
        no_data_found
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
          return nil
        end
      end
    end

    def get_url(dataset)
      'http://api.nea.gov.sg/api/WebAPI/?dataset=' + dataset + '&keyref=' + ENV['WEATHER_API_KEYREF']
    end

    def no_data_found
      'Sorry, I do not have data about the place you are asking for...'
    end

    def external_api_error
      'Sorry, something is going wrong with our external info provider... Please try again later'
    end
  end
end
