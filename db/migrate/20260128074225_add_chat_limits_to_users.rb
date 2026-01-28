class AddChatLimitsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :chat_token_count, :integer
    add_column :users, :role, :string
    add_column :users, :token_reset_at, :datetime
  end
end
