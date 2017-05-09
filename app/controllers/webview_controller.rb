# Facebook webview
class WebviewController < ApplicationController
  def locations
    @locations = KnownLocation.where(type: 'location').map { |kl| kl.name.capitalize }
  end

  def reply_to_location
    request_message = params[:location]
    uid = params[:uid]
    user = User.find_or_create_by(uid: uid)

    Message.create(body: request_message, user: user, kind: 'incoming')

    puts "[debuz] got from Facebook WEBVIEW... #{request_message}"
    chat_service = ChatService.new(uid)
    chat_service.execute(request_message)
    FacebookMessengerService.deliver(uid, chat_service.response_message, chat_service.quick_replies, chat_service.response_template)
    FacebookMessengerService.deliver(uid, chat_service.follow_up_response_message, chat_service.quick_replies) if chat_service.follow_up_response_message.present?
  end
end
