# frozen_string_literal: true
# config/initializers/facebook_messenger.rb

unless Rails.env.production?
  bot_files = Dir[Rails.root.join('app', 'bot', '**', '*.rb')]
  bots_reloader = ActiveSupport::FileUpdateChecker.new(bot_files) do
    bot_files.each { |file| require_dependency file }
  end

  ActionDispatch::Callbacks.to_prepare do
    bots_reloader.execute_if_updated
  end

  bot_files.each { |file| require_dependency file }
end
