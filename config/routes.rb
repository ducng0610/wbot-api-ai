# frozen_string_literal: true
Rails.application.routes.draw do
  post '/start', to: 'api/chat#start'
  post '/message', to: 'api/chat#message'

  mount Facebook::Messenger::Server, at: 'bot'
end
