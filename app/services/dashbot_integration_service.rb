# frozen_string_literal: true
class DashbotIntegrationService
  class << self
    def incoming(text, uid)
      fire_request(text, uid, 'incoming')
    end

    def outgoing(text, uid)
      fire_request(text, uid, 'outgoing')
    end

    private

    def fire_request(text, uid, type)
      api_key = ENV['DASHBOT_API_KEY']
      url = "https://tracker.dashbot.io/track?platform=generic&v=0.8.2-rest&type=#{type}&apiKey=#{api_key}"

      params = {
        text: text,
        userId: uid
      }

      RestClient.post(url, params.to_json, content_type: 'application/json') do |response, _request, _result|
        if response.code == 200
          puts "[debuz] Successfully recorded to Dashbot"
        else
          puts "[debuz] Dashbot API error: #{response.body}"
        end
      end
    end
  end
end
