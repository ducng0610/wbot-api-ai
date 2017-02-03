namespace :keep_server_awake do
  desc 'keep_server_awake'
  task go: :environment do
    RestClient.get('https://rth-wbot2.herokuapp.com/bot')
  end
end
