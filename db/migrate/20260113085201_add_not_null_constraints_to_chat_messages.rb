class AddNotNullConstraintsToChatMessages < ActiveRecord::Migration[8.1]
  def change
    change_column_null :chat_messages, :role, false
    change_column_null :chat_messages, :content, false
  end
end
