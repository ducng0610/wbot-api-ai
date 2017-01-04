require 'wit'
require 'singleton'

class WitExtension
  include Singleton

  def initialize
    access_token = ENV['server_access_token']
    actions = {
      send: lambda do |_request, response|
        PubnubExtension.instance.client.publish(message: response['text'], channel: @conversation.uid)
        @conversation.messages.create(body: response['text'], kind: 'outgoing')
        puts("sending... #{response['text']}")
      end,

      getForecast: lambda do |request|
                     context = request['context']
                     entities = request['entities']

                     location = first_entity_value(entities, 'location') || context['location']
                     intent = first_entity_value(entities, 'intent') || context['intent']

                     if location && intent == 'weather'
                       context['forecast'] = search_forecast(location)
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

  def search_forecast(location)
    # perform search query magic
    puts 'Searching for weather...'
    'Sunny Randomy'
  end
end
