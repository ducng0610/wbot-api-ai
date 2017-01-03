require 'wit'
require 'singleton'

class WitExtension
  include Singleton

  def initialize
    access_token = '7DO5OGFBNMKCLW57NIIO5I7CS27RAJCU'
    actions = {
      send: lambda do |_request, response|
        PubnubExtension.instance.client.publish(message: response['text'], channel: @conversation.uid)
        @conversation.messages.create(body: response['text'], kind: 'outgoing')
        puts("sending... #{response['text']}")
      end,

      findTheatre: lambda do |request|
                     context = request['context']
                     entities = request['entities']

                     showTime = first_entity_value(entities, 'datetime') || context['showTime']
                     movie = first_entity_value(entities, 'movie') || context['movue']

                     if showTime
                       context['showTime'] = showTime
                       context.delete('missingTime')
                     else
                       context['missingTime'] = true
                     end

                     context['movie'] = movie if movie

                     if showTime && movie
                       theatre = search_theatres(showTime, movie)
                       context['theatre'] = theatre
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

  def search_theatres(_showTime, _movie)
    # perform search query magic
    puts 'Searching for Theatre...'
    'Random Theatre'
  end
end
