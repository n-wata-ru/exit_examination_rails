class ChatThreadsController < ApplicationController
  before_action :authenticate_user!
  before_action :disable_rack_lock, only: [ :stream ]

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

    # メッセージ履歴を取得
    messages = @chat_thread.chat_messages.order(:created_at).pluck(:role, :content).map do |role, message_content|
      { role: role, content: message_content }
    end

    full_text = +""
    service = OpenAi::ChatService.new

    # Enumeratorを使って直接ストリーミング
    self.response_body = Enumerator.new do |yielder|
      begin
        # 接続確立メッセージ
        yielder << "data: #{JSON.generate({ status: "connected" })}\n\n"

        # ストリーミングでAI応答を取得
        service.generate_chat_response_stream(messages: messages) do |chunk|
          full_text << chunk
          yielder << "data: #{JSON.generate({ content: chunk })}\n\n"
        end

        # 完了したらDBに保存
        @chat_thread.chat_messages.create!(
          user: current_user,
          role: "assistant",
          content: full_text.strip
        )

        # 完了メッセージ
        yielder << "data: #{JSON.generate({ done: true })}\n\n"
      rescue StandardError => e
        Rails.logger.error("Stream error: #{e.message}")
        yielder << "data: #{JSON.generate({ error: e.message })}\n\n"
      end
    end
  end

  def disable_rack_lock
    # このアクションだけRack::Lockを無効化
    request.env.delete("rack.mutex")
  end
end
