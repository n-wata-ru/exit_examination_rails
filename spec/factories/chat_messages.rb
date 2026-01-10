FactoryBot.define do
  factory :chat_message do
    user { nil }
    chat_thread { nil }
    role { "MyString" }
    content { "MyText" }
  end
end
