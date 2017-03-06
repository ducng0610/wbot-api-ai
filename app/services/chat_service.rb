# frozen_string_literal: true
class ChatService
  def initialize(uid)
    @client = ApiAiRuby::Client.new(
      client_access_token: ENV['API_AI_CLIENT_ACCESS_TOKEN'],
      api_session_id: uid
    )
  end

  def execute(message)
    api_ai_response = @client.text_request(message)
    api_ai_response_message = api_ai_response[:result][:fulfillment][:speech]
    action_incomplete = api_ai_response[:result][:actionIncomplete]
    action = api_ai_response[:result][:action]

    if action_incomplete
      @response_message = api_ai_response_message
      @quick_replies = case action
                       when 'ask.current.weather'
                         ['location@#$'] + KnownLocation.where(type: 'location').sample(5).map{ |kl| kl.name.capitalize }
                       when 'ask.psi', 'ask.weather.forecast'
                         %w(North West East South Central)
                       end
      return
    end

    case action
    when 'ask.current.weather'
      @response_message = search_forecast(api_ai_response[:result][:parameters][:location])
    when 'ask.psi'
      @response_message = search_psi(api_ai_response[:result][:parameters][:region])
    when 'ask.weather.forecast'
      @response_template = search_24HoursForecast(api_ai_response[:result][:parameters][:region])
    when 'add.help.quickreplies'
      @response_message = api_ai_response_message
      @quick_replies = ['Current weather', '24-Hour Forecast', 'PSI']
    else
      @response_message = api_ai_response_message
    end
  end

  attr_reader :response_message, :quick_replies, :response_template

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
end
