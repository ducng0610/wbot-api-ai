# frozen_string_literal: true
# # frozen_string_literal: true
# require 'wit'
# require 'singleton'

# class WitService
#   include Singleton

#   def initialize
#     actions = {
#       send: lambda do |_request, response|
#         puts("[debuz] got response... #{response['text']}")

#         if @custom_response
#           puts("[debuz] custom response... #{@custom_response}")
#           message = Message.create(body: @custom_response, kind: 'outgoing', conversation: @conversation)
#           @custom_response = nil
#         else
#           message = Message.create(body: response['text'], kind: 'outgoing', conversation: @conversation)
#           if response['quickreplies'].present?
#             response['quickreplies'].each do |quick_reply|
#               QuickReply.create(
#                 title: quick_reply,
#                 content_type: 'text',
#                 payload: 'empty',
#                 message: message
#               )
#             end
#           end
#         end

#         # Send the message back to facebook user
#         message.digest
#       end,

#       getForecast:
#         lambda do |request|
#           return handle_request(request, 'location', 'getForecast')
#         end,

#       get24HoursForecast:
#         lambda do |request|
#           return handle_request(request, 'region', 'get24HoursForecast')
#         end,

#       getPsi:
#         lambda do |request|
#           return handle_request(request, 'region', 'getPsi')
#         end
#     }

#     access_token = ENV['server_access_token']
#     @client = Wit.new(access_token: access_token, actions: actions)
#   end

#   attr_reader :client

#   def set_conversation(conversation)
#     @conversation = conversation
#   end

#   def set_custom_response(custom_response)
#     @custom_response = custom_response
#   end

#   private

#   def first_entity_value(entities, entity)
#     return nil unless entities.key? entity
#     val = entities[entity][0]['value']
#     return nil if val.nil?
#     val.is_a?(Hash) ? val['value'] : val
#   end

#   def handle_request(request, location_type, action)
#     context = request['context']
#     entities = request['entities']
#     location = first_entity_value(entities, 'location') || context['location']
#     # intent = first_entity_value(entities, 'intent') || context['intent']

#     known_location = KnownLocation.get_known_location(location, location_type)
#     if known_location
#       location = known_location
#       context['location'] = known_location
#     else
#       location = KnownLocation.guess_known_location(location, location_type)
#       context['guess_location'] = location
#     end

#     if location
#       case action
#       when 'getForecast'
#         context = search_forecast(location, context)
#       when 'get24HoursForecast'
#         context = search_24HoursForecast(location, context)
#       when 'getPsi'
#         context = search_psi(location, context)
#       else
#       end

#       new_context = {}
#     else
#       new_context = context
#     end

#     @conversation.update(context: new_context)
#     context
#   end

#   def search_forecast(location, context)
#     puts "[debuz] Searching for weather in #{location} ..."
#     forecast = WeatherService.search_forecast(location)
#     if forecast.present?
#       context['forecast'] = forecast
#     else
#       no_data_found
#     end

#     context
#   end

#   def search_24HoursForecast(location, context)
#     puts '[debuz] Searching for 24-hour forecast #{location} ...'
#     forecast = WeatherService.search_24HoursForecast(location)
#     if forecast.present?
#       context['24HoursForecast'] = forecast
#     else
#       no_data_found
#     end

#     context
#   end

#   def search_psi(location, context)
#     puts "[debuz] Searching for psi forecast in #{location} ..."
#     hour_psi = WeatherService.search_hour_psi(location)
#     day_psi = WeatherService.search_day_psi(location)
#     if hour_psi.present? && day_psi.present?
#       context['hour_psi'] = hour_psi
#       context['day_psi'] = day_psi
#     else
#       no_data_found
#     end

#     context
#   end

#   def no_data_found
#     # TODO
#   end
# end
