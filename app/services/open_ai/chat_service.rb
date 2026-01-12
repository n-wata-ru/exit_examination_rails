module OpenAi
  class ChatService
    def initialize
      @client = ::OpenAI::Client.new(
        api_key: ENV["OPENAI_API_KEY"]
      )
    end

    def generate_chat_response(messages:)
      @client.chat.completions.create(
        model: "gpt-4",
        messages: messages,
        temperature: 0.7
      )
    end

    def analyze_coffee_beans(messages:)
      @client.chat(
        parameters: {
          model: "gpt-4",
          messages: messages,
          temperature: 0.7,
          stream: proc { |chunk, _bytesize| yield chunk if block_given? }
        }
      )
    end
  end
end
