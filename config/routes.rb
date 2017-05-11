# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :admins

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'home#index'

  # telegram
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'

  # api for testing only
  post '/message', to: 'api/chat#message'

  # webview
  resources :webview do
    get 'fallback', on: :collection
    get 'locations', on: :collection
    post 'reply_to_location', on: :collection
  end

  get 'acp_addon/chat_histories' => 'acp_addon#chat_histories'
  get 'acp_addon/statistic' => 'acp_addon#statistic'
  get 'acp_addon/chat_history/:id' => 'acp_addon#chat_history'
  post 'acp_addon/send_message' => 'acp_addon#send_message'

  mount Facebook::Messenger::Server, at: 'bot'
end
