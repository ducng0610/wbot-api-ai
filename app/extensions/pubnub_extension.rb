require 'pubnub'
require 'singleton'

class PubnubExtension
  include Singleton

  def initialize
    @client = Pubnub.new(
      subscribe_key: 'sub-c-f7a78ae4-829f-11e6-974e-0619f8945a4f',
      publish_key: 'pub-c-1c361ca2-73cf-4ea3-bdab-eefaa0d3187d',
      logger: Rails.logger,
      error_callback: lambda do |msg|
        puts "Error callback says: #{msg.inspect}"
      end,
      connect_callback: lambda do |msg|
        puts "CONNECTED: #{msg.inspect}"
      end
    )
  end

  attr_reader :client
end
