# frozen_string_literal: true
class Api::ChatController < ApplicationController
  def message
    chat_service = ChatService.new(params[:uid])
    chat_service.execute(params[:message])
    render json: { response_message: chat_service.response_message,
                   response_template: chat_service.response_template,
                   quick_replies: chat_service.quick_replies }
  end
end
