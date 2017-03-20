# frozen_string_literal: true
namespace :mass_reply_all_users do
  desc 'mass_reply_all_users'
  task go: :environment do
    user_ids = User.pluck(:uid)
    user_ids.each do |id|
      FacebookMessengerService.deliver(id, 'Hi, thank you for testing & supporting Wbot. We are trying our best to fulfill your experience! Thank you!')
    end
  end
end
