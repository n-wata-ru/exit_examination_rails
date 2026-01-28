# == Schema Information
#
# Table name: users
#
#  id: integer,
#  chat_token_count: integer,
#  created_at: datetime,
#  email: string,
#  encrypted_password: string,
#  name: string,
#  remember_created_at: datetime,
#  reset_password_sent_at: datetime,
#  reset_password_token: string,
#  role: string,
#  token_reset_at: datetime,
#  updated_at: datetime)
#
#

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user-#{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    # 追加カラムのデフォルト値
    role { 'user' }
    chat_token_count { 0 }
    token_reset_at { nil }

    # 管理者用のtrait
    trait :admin do
      role { 'admin' }
      sequence(:email) { |n| "admin-#{n}@example.com" }
    end

    # トークン消費済みユーザー用のtrait
    trait :token_exhausted do
      chat_token_count { 300 }
      token_reset_at { Time.current.end_of_month }
    end
  end
end
