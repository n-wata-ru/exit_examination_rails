class ChatMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_chat_limits, only: [ :create ]

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

    # トークンを消費
    current_user.consume_tokens!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("messages", partial: "chat_messages/user_message", locals: { message: @user_message }),
          turbo_stream.append("messages", "<div id='trigger-sse' data-thread-id='#{@chat_thread.id}'></div>".html_safe),
          turbo_stream.replace("token-info", partial: "shared/token_info", locals: { user: current_user })
        ]
      end
      format.html { redirect_to chat_thread_path(@chat_thread), notice: "メッセージを送信しました。" }
    end
  end

  private

  def check_chat_limits
    unless current_user.can_send_chat_message?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("token-info", partial: "shared/token_info", locals: { user: current_user }),
                 status: :too_many_requests
        end
        format.json do
          render json: {
            error: "チャット利用制限に達しました",
            is_limited: true,
            remaining_tokens: current_user.remaining_tokens
          }, status: :too_many_requests
        end
      end
    end
  end

  def message_params
    # authenticity_tokenとcommitは除外
    params.except(:authenticity_token, :commit).permit(:content, :chat_thread_id)
  end
end
