class AddNotNullToChatThreadsTitle < ActiveRecord::Migration[8.1]
  def change
    change_column_null :chat_threads, :title, false
  end
end
