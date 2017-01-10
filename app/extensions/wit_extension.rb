require 'wit'
require 'singleton'

class WitExtension
  include Singleton

  def initialize
    access_token = ENV['server_access_token']
    actions = {
      send: lambda do |_request, response|
        @conversation.messages.create(body: response['text'], kind: 'outgoing')
        puts("[debuz] got response... #{response['text']}")
      end,

      getForecast: lambda do |request|
                     context = request['context']
                     entities = request['entities']

                     location = first_entity_value(entities, 'location') || context['location']
                     intent = first_entity_value(entities, 'intent') || context['intent']

                     if location
                       forecast = search_forecast(location)
                       context['forecast'] = forecast if forecast.present?
                       new_context = {}
                     else
                       new_context = context
                     end

                     @conversation.update(context: new_context)
                     return context
                   end
    }

    @client = Wit.new(access_token: access_token, actions: actions)
  end

  attr_reader :client

  def set_conversation(conversation)
    @conversation = conversation
  end

  private

  def first_entity_value(entities, entity)
    return nil unless entities.key? entity
    val = entities[entity][0]['value']
    return nil if val.nil?
    val.is_a?(Hash) ? val['value'] : val
  end

  def search_forecast(_location)
    puts "[debuz] Searching for weather in #{_location} ..."
    WeatherExtension.search_2hour_nowcast(_location)
  end
end
