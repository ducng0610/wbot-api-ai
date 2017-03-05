# frozen_string_literal: true
class Api::ChatController < ApplicationController
  def start
    create_conversation
    render json: @conversation
  end

  def message
    validate_message_params
    set_conversation
    create_incoming_message(params[:message])
    WitService.instance.client.run_actions(@conversation.uid, params[:message], @conversation.context.to_h)

    render json: @conversation.messages.order(created_at: :asc).last
  end

  private

  def validate_message_params
    param! :message, String, required: true
    param! :uid, String, required: true
  end

  def create_conversation
    @conversation = Conversation.create(uid: Time.now.to_i)
    WitService.instance.set_conversation(@conversation)
  end

  def create_incoming_message(message)
    create_message('incoming', message)
  end

  def create_message(kind, message)
    @message = @conversation.messages.create(
      body: message,
      kind: kind
    )
  end

  def set_conversation
    @conversation = Conversation.find_by(uid: params[:uid])
    WitService.instance.set_conversation(@conversation)
  end
end
