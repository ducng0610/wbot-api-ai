Rails.application.routes.draw do
  post '/start', to: 'api/chat#start'
  post '/message', to: 'api/chat#message'
end
