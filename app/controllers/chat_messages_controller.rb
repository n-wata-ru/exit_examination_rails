class ChatMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    content = message_params[:content]
    chat_thread_id = message_params[:chat_thread_id]

    # スレッドIdが設定されていれば既存スレッドを使用
    if chat_thread_id.present?
      @chat_thread = current_user.chat_threads.find(chat_thread_id)
    else
      # なければ仮のtitleで新規スレッド作成
      title = content.truncate(30, omission: "...")
      @chat_thread = current_user.chat_threads.create!(title: title)
    end

    # ユーザーのメッセージを作成
    @user_message = @chat_thread.chat_messages.create!(
      user: current_user,
      role: "user",
      content: content
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("messages", partial: "chat_messages/user_message", locals: { message: @user_message }),
          turbo_stream.append("messages", "<div id='trigger-sse' data-thread-id='#{@chat_thread.id}'></div>".html_safe)
        ]
      end
      format.html { redirect_to chat_thread_path(@chat_thread), notice: "メッセージを送信しました。" }
    end
  end

  def stream
    @chat_thread = current_user.chat_threads.find(params[:id])

    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"

    # SSEストリーム
    sse = Sse.new(response.stream, retry: 300, event: "message")

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

  def message_params
    # authenticity_tokenとcommitは除外
    params.except(:authenticity_token, :commit).permit(:content, :chat_thread_id)
  end
end
