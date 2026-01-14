class ChatThreadsController < ApplicationController
  before_action :authenticate_user!

  require_relative "concerns/sse"

  def index
    @chat_threads = current_user.chat_threads.order(updated_at: :desc)
    @current_thread = @chat_threads.first
    @messages = @current_thread&.chat_messages&.order(created_at: :asc) || []
    @is_new_thread = @current_thread.nil?
  end

  def show
    @chat_threads = current_user.chat_threads.order(updated_at: :desc)
    @current_thread = @chat_threads.find(params[:id])
    @messages = @current_thread.chat_messages.order(created_at: :asc)
    @is_new_thread = @current_thread.nil?
  end

  def stream
    @chat_thread = current_user.chat_threads.find(params[:id])

    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"

    # SSEストリーム
    sse = SSE.new(response.stream, retry: 300, event: "message")

    begin
      # メッセージ履歴を取得
      messages = @chat_thread.chat_messages.order(:created_at).pluck(:role, :content).map do |role, message_content|
        { role: role, content: message_content }
      end

      full_text = +""
      service = OpenAi::ChatService.new

      # ストリーミングでAI応答を取得
      service.generate_chat_response_stream(messages: messages) do |chunk|
        full_text << chunk
        sse.write({ content: chunk })
      end

      # 完了したらDBに保存
      @chat_thread.chat_messages.create!(
        user: current_user,
        role: "assistant",
        content: full_text.strip
      )

      sse.write({ done: true })
    rescue IOError
      # クライアントが切断した場合
    ensure
      sse.close
    end
  end
end
