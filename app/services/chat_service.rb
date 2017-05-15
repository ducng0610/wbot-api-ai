# frozen_string_literal: true
class ChatService
  def initialize(uid, platform = 'facebook')
    @client = ApiAiRuby::Client.new(
      client_access_token: ENV['API_AI_CLIENT_ACCESS_TOKEN'],
      api_session_id: uid
    )
    @platform = platform
  end

  def execute(message)
    api_ai_response = @client.text_request(message)
    api_ai_response_message = api_ai_response[:result][:fulfillment][:speech]
    action_incomplete = api_ai_response[:result][:actionIncomplete]
    action = api_ai_response[:result][:action]

    if action_incomplete
      @response_message = api_ai_response_message

      case action
      when 'ask.current.weather'
        # Override with template
        @response_template = {
          "attachment": {
            "type": 'template',
            "payload": {
              "template_type": 'button',
              "text": @response_message,
              "buttons": [
                {
                  "type": 'web_url',
                  "url": "#{ENV['BASE_URL']}/webview/locations",
                  "title": 'Choose from list',
                  "webview_height_ratio": 'tall',
                  "messenger_extensions": true,
                  "fallback_url": "#{ENV['BASE_URL']}/webview/fallback"
                }
              ]
            }
          }
        }.to_json

        @quick_replies = ['location@#$'] + KnownLocation.where(type: 'location').sample(5).map { |kl| kl.name.capitalize }
        @follow_up_response_message = 'Some suggestions for you...'
      when 'ask.psi', 'ask.weather.forecast'
        @quick_replies = %w(North West East South Central)
      end

      return
    end

    # if action is complete, move to backend logic to handle request

    case action
    when 'ask.current.weather'
      @response_message = search_forecast(api_ai_response[:result][:parameters][:location])
    when 'ask.psi'
      @response_message = search_psi(api_ai_response[:result][:parameters][:region])
    when 'ask.weather.forecast'
      @response_template = search_24HoursForecast(api_ai_response[:result][:parameters][:region])

      if @platform == 'telegram'
        # This is for telegram only, because Telegram cannot display facebook template
        @response_template = translate_24h_forecast_to_template_telegram(@response_template)
      end
    when 'add.help.quickreplies'
      @response_message = api_ai_response_message
      @quick_replies = ['Current weather', '24-Hour Forecast', 'PSI']
    else
      @response_message = api_ai_response_message
    end

    case action
    when 'ask.current.weather', 'ask.psi', 'ask.weather.forecast', 'tell.joke', 'input.unknown'
      @follow_up_response_message = 'Can I help you with other weather information?'
      @quick_replies = ['Current weather', '24-Hour Forecast', 'PSI']
    end
  end

  attr_reader :response_message, :quick_replies, :response_template, :follow_up_response_message

  private

  def search_forecast(location)
    WeatherService.search_forecast(location)
  end

  def search_24HoursForecast(region)
    WeatherService.search_24HoursForecast(region)
  end

  def search_psi(region)
    WeatherService.search_psi(region)
  end

  def translate_24h_forecast_to_template_telegram(template_str)
    template = JSON.parse(template_str)
    body_title = '<b>' + template['attachment']['payload']['elements'].first['title'] + '</b>' + "\n"
    body_content = '<i>' + template['attachment']['payload']['elements'].last(3).map { |w| w.values.join(' - ') }.join("\n") + '</i>'
    body_title + body_content
  end
end
