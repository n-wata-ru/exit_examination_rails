FactoryBot.define do
  factory :chat_thread do
    association :user
    title { "MyString" }
  end
end
