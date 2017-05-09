# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :admins
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'home#index'

  # telegram
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'

  # api for testing only
  post '/start', to: 'api/chat#start'
  post '/message', to: 'api/chat#message'

  # webview
  resources :webview do
    get 'fallback', on: :collection
    get 'locations', on: :collection
    post 'reply_to_location', on: :collection
  end

  mount Facebook::Messenger::Server, at: 'bot'
end
