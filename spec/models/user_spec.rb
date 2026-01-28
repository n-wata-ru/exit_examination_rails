require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:tasting_notes).dependent(:destroy) }
    it { should have_many(:coffee_beans).dependent(:destroy) }
    it { should have_many(:chat_threads).dependent(:destroy) }
    it { should have_many(:chat_messages).dependent(:destroy) }
  end

  describe 'Devise モジュール' do
    it 'database_authenticatableが有効であること' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end
  end

  describe 'ログインバリデーション' do
    it 'nameが必須であること' do
      user = User.new(name: nil, email: 'test@example.com', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("を入力してください")
    end

    it 'emailが必須であること' do
      user = User.new(name: 'test', email: nil, password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("を入力してください")
    end

    it 'パスワードが必須であること' do
      user = User.new(name: 'test', email: 'test@example.com', password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("を入力してください")
    end
  end

  describe 'enum' do
    it 'roleのenumが正しく定義されていること' do
      user = create(:user)
      expect(user.user?).to be true
      expect(user.admin?).to be false
    end

    it '管理者の場合、adminがtrueであること' do
      admin = create(:user, :admin)
      expect(admin.admin?).to be true
      expect(admin.user?).to be false
    end
  end

  describe 'トークン管理' do
    let(:user) { create(:user) }

    describe '#can_send_chat_message?' do
      context '通常のユーザーの場合' do
        it 'トークンが残っていれば true を返すこと' do
          expect(user.can_send_chat_message?).to be true
        end

        it 'トークンが上限に達していれば false を返すこと' do
          user.update(chat_token_count: 300, token_reset_at: Time.current.end_of_month)
          expect(user.can_send_chat_message?).to be false
        end
      end

      context '管理者の場合' do
        let(:admin) { create(:user, :admin) }

        it 'トークン制限なく true を返すこと' do
          admin.update(chat_token_count: 999, token_reset_at: Time.current.end_of_month)
          expect(admin.can_send_chat_message?).to be true
        end
      end
    end

    describe '#remaining_tokens' do
      it '残りトークン数を返すこと' do
        user.update(chat_token_count: 100, token_reset_at: Time.current.end_of_month)
        expect(user.remaining_tokens).to eq(200)
      end

      it 'トークンが0の場合、上限値を返すこと' do
        expect(user.remaining_tokens).to eq(300)
      end
    end

    describe '#consume_tokens!' do
      it 'トークンが消費されること' do
        expect { user.consume_tokens! }.to change { user.reload.chat_token_count }.by(10)
      end

      it '管理者はトークンが消費されないこと' do
        admin = create(:user, :admin)
        expect { admin.consume_tokens! }.not_to change { admin.reload.chat_token_count }
      end
    end

    describe '#is_chat_limited?' do
      it 'トークンが残っていれば false を返すこと' do
        expect(user.is_chat_limited?).to be false
      end

      it 'トークンが上限に達していれば true を返すこと' do
        user.update(chat_token_count: 300, token_reset_at: Time.current.end_of_month)
        expect(user.is_chat_limited?).to be true
      end
    end

    describe '#reset_tokens_if_needed!' do
      context 'token_reset_atがnilの場合' do
        it 'トークンがリセットされること' do
          user.update(chat_token_count: 100, token_reset_at: nil)
          user.send(:reset_tokens_if_needed!)
          expect(user.chat_token_count).to eq(0)
          expect(user.token_reset_at).not_to be_nil
        end
      end

      context 'token_reset_atが先月の場合' do
        it 'トークンがリセットされること' do
          user.update(chat_token_count: 100, token_reset_at: 1.month.ago)
          user.send(:reset_tokens_if_needed!)
          expect(user.chat_token_count).to eq(0)
        end
      end

      context 'token_reset_atが今月の場合' do
        it 'トークンがリセットされないこと' do
          user.update(chat_token_count: 100, token_reset_at: Time.current.end_of_month)
          user.send(:reset_tokens_if_needed!)
          expect(user.chat_token_count).to eq(100)
        end
      end
    end
  end
end
