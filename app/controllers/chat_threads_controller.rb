class ChatThreadsController < ApplicationController
  before_action :authenticate_user!

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
  end

  def destroy
    @chat_thread = current_user.chat_threads.find(params[:id])
    @chat_thread.destroy
    redirect_to chat_threads_path, notice: 'スレッドを削除しました。'
  end
end
