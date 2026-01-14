module OpenAi
  class ChatService
    def initialize
      @client = OpenAI::Client.new(
        access_token: ENV.fetch("OPENAI_API_KEY")
      )
    end

    def generate_chat_response(messages:)
      full_text = +""

      begin
        # gem 8.3.0の正しい形式
        @client.chat(
          parameters: {
            model: "gpt-4o",
            messages: messages,
            temperature: 0.7,
            stream: proc do |chunk, _bytesize|
              content = chunk.dig("choices", 0, "delta", "content")
              full_text << content if content
            end
          }
        )

        full_text.strip
      rescue => e
        Rails.logger.error("OpenAI API Error: #{e.message}")
        Rails.logger.error("Error class: #{e.class}")
        Rails.logger.error("Error backtrace: #{e.backtrace.first(5).join("\n")}")
        Rails.logger.error("Messages: #{messages.inspect}")
        raise
      end
    end

    def generate_chat_response_stream(messages:, &block)
      begin
        @client.chat(
          parameters: {
            model: "gpt-4o",
            messages: messages,
            temperature: 0.7,
            stream: proc do |chunk, _bytesize|
              content = chunk.dig("choices", 0, "delta", "content")
              yield content if content && block_given?
            end
          }
        )
      rescue => e
        Rails.logger.error("OpenAI Streaming API Error: #{e.message}")
        raise
      end
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
