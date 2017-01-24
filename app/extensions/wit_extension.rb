# frozen_string_literal: true
require 'wit'
require 'singleton'

class WitExtension
  include Singleton

  def initialize
    access_token = ENV['server_access_token']
    actions = {
      send: lambda do |_request, response|
        message = Message.new(body: response['text'], kind: 'outgoing', conversation: @conversation)
        if response['quickreplies'].present?
          response['quickreplies'].each do |quick_reply|
            QuickReply.create(
              title: quick_reply,
              content_type: 'text',
              payload: 'empty',
              message: message
            )
          end
        end

        message.save
        puts("[debuz] got response... #{response['text']}")
      end,

      getForecast: lambda do |request|
                     context = request['context']
                     entities = request['entities']

                     location = first_entity_value(entities, 'location') || context['location']
                     intent = first_entity_value(entities, 'intent') || context['intent']

                     if location
                       forecast = search_forecast(location)
                       if forecast.present?
                         context['forecast'] = forecast
                       else
                         context['missingData'] = 'true'
                       end
                       new_context = {}
                     else
                       new_context = context
                     end

                     @conversation.update(context: new_context)
                     return context
                   end,

      get24HoursForecast: lambda do |request|
                            context = request['context']
                            entities = request['entities']

                            location = first_entity_value(entities, 'location') || context['location']
                            intent = first_entity_value(entities, 'intent') || context['intent']

                            if location
                              context['24HoursForecast'] = search_24HoursForecast(location)
                              new_context = {}
                            else
                              new_context = context
                            end

                            @conversation.update(context: new_context)
                            return context
                          end,

      getPsi: lambda do |request|
                context = request['context']
                entities = request['entities']

                location = first_entity_value(entities, 'location') || context['location']
                intent = first_entity_value(entities, 'intent') || context['intent']

                if location
                  hour_psi = search_hour_psi(location)
                  day_psi = search_day_psi(location)
                  if hour_psi.present? && day_psi.present?
                    context['hour_psi'] = hour_psi
                    context['day_psi'] = day_psi
                  else
                    context['missingData'] = 'true'
                  end
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
    puts "[debuz] Searching for weather in #{location} ..."
    WeatherExtension.search_forecast(location)
  end

  def search_24HoursForecast(location)
    puts '[debuz] Searching for 24-hour forecast #{location} ...'
    WeatherExtension.search_24HoursForecast(location)
  end

  def search_hour_psi(location)
    puts "[debuz] Searching for hour_psi forecast in #{location} ..."
    WeatherExtension.search_hour_psi(location)
  end

  def search_day_psi(location)
    puts "[debuz] Searching for day_psi forecast in #{location} ..."
    WeatherExtension.search_day_psi(location)
  end
end
