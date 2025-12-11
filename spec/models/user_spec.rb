require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:tasting_notes).dependent(:destroy) }
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
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'emailが必須であること' do
      user = User.new(name: 'test', email: nil, password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'パスワードが必須であること' do
      user = User.new(name: 'test', email: 'test@example.com', password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end
end
