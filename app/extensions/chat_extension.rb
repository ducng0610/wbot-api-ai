# frozen_string_literal: true
class ChatExtension
  class << self
    def response(message, uid)
      puts "[debuz] asking WIT for... #{message}"
      find_or_initialize_conversation(uid)
      create_incoming_message(message)
      WitExtension.instance.client.run_actions(@conversation.uid, message, @conversation.context.to_h)
    end

    private

    def find_or_initialize_conversation(uid)
      @conversation = Conversation.find_or_create_by(uid: uid)
      WitExtension.instance.set_conversation(@conversation)
    end

    def create_incoming_message(message)
      create_message('incoming', message)
    end

    def create_message(kind, message)
      @message = @conversation.messages.create(
        body: message,
        kind: kind
      )
    end
  end
end
