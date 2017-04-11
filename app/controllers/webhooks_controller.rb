# frozen_string_literal: true
# Telegram platform only
class WebhooksController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def callback
    dispatcher.new(webhook, user).process
    render nothing: true, head: :ok
  end

  def webhook
    params['webhook']
  end

  def dispatcher
    BotMessageDispatcher
  end

  def from
    webhook[:message][:from]
  end

  def user
    @user ||= User.where(telegram_id: from[:id]).first || register_user
  end

  def register_user
    @user = User.create(telegram_id: from[:id], uid: from[:id])
    @user.update_attributes!(first_name: from[:first_name], last_name: from[:last_name])
    @user
  end
end
