require 'rails_helper'

RSpec.describe ChatThread, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:chat_messages).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:title) }

    describe 'dependent destroy' do
      let!(:chat_thread) { FactoryBot.create(:chat_thread) }

      it 'userが削除されたら関連するchat_threadsも削除されること' do
        expect { chat_thread.user.destroy }.to change { ChatThread.count }.by(-1)
      end
    end
  end
end
