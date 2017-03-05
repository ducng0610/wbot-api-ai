# frozen_string_literal: true
class ChatService
  def initialize(uid)
    @client = ApiAiRuby::Client.new(
      client_access_token: ENV['API_AI_CLIENT_ACCESS_TOKEN'],
      api_session_id: uid
    )
    @facebook_messenger = FacebookMessengerService.new(uid)
  end

  def response(message)
    response = @client.text_request(message)

    action_incomplete = response[:result][:actionIncomplete]
    if action_incomplete
      @facebook_messenger.deliver(response[:result][:fulfillment][:speech])
      return
    end

    action = response[:result][:action]
    binding.pry
  end

  private
end
