require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:chat_thread) { FactoryBot.create(:chat_thread, user: user) }
  let(:chat_message) { FactoryBot.create(:chat_message, user: user, chat_thread: chat_thread) }

  subject { FactoryBot.build(:chat_message, user: user, chat_thread: chat_thread) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:chat_thread) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:chat_thread) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:content) }

    describe 'dependent destroy' do
      it 'chat_threadが削除されたら関連するchat_messagesも削除されること' do
        chat_thread.chat_messages.create!(
          user: user,
          content: 'Hello',
          role: 'user'
        )

        expect { chat_thread.destroy }.to change { ChatMessage.count }.by(-1)
      end
    end
  end
end
