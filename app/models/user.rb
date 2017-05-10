# frozen_string_literal: true
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :get_facebook_profile

  field :uid, type: String
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :gender, type: String
  field :source, type: String

  has_many :messages

  validates_uniqueness_of :uid

  def get_facebook_profile
    return if source != 'facebook'

    url = "https://graph.facebook.com/v2.6/#{uid}?fields=first_name,last_name,gender&access_token=#{ENV['ACCESS_TOKEN']}"

    RestClient.get(url) do |response, _request, _result|
      if response.code == 200
        body = JSON.parse(response.body)
        update_attributes(
          first_name: body['first_name'],
          last_name: body['last_name'],
          gender: body['gender']
        )
      else
        puts "[debuz] Cannot get user's facebook profile"
      end
    end
  end
end
