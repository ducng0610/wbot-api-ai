class FacebookMessengerService
  def initialize(uid)
    @uid = uid
  end

  def deliver(message)
    puts "[debuz] sending '#{message}' to user '#{@uid}'"
  end
end