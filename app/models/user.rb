class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Constants
  CHAT_TOKEN_LIMIT = 300
  CHAT_TOKEN_PER_MESSAGE = 10

  # Enum
  enum :role, { user: "user", admin: "admin" }, default: "user"

  # Associations
  has_many :coffee_beans, dependent: :destroy
  has_many :tasting_notes, dependent: :destroy
  has_many :chat_threads, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  # Validations
  validates :name, presence: true

  # チャット送信可能かチェック
  def can_send_chat_message?
    return true if admin?  # adminは制限なし

    reset_tokens_if_needed!
    chat_token_count < CHAT_TOKEN_LIMIT
  end

  # 残トークン数を取得
  def remaining_tokens
    reset_tokens_if_needed!
    CHAT_TOKEN_LIMIT - chat_token_count
  end

  # トークンを消費
  def consume_tokens!
    return if admin?

    reset_tokens_if_needed!
    increment!(:chat_token_count, CHAT_TOKEN_PER_MESSAGE)
  end

  # チャット制限中かチェック
  def is_chat_limited?
    !can_send_chat_message?
  end

  private

  # トークンリセットが必要ならリセット（毎月1日）
  def reset_tokens_if_needed!
    if token_reset_at.nil? || token_reset_at < Time.current.beginning_of_month
      update!(
        chat_token_count: 0,
        token_reset_at: Time.current.end_of_month
      )
    end
  end
end
