require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  describe 'GET /users/sign_in' do
    it 'ログイン画面が表示されること' do
      get new_user_session_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("ログイン")
    end
  end

  describe 'POST /users/sign_in' do
    let(:user) { create(:user) }

    context '正しい認証情報の場合' do
      it 'ログインできること' do
        post user_session_path, params: {
          user: { email: user.email, password: user.password }
        }
        # TODO: 一覧が実装されたら修正
        expect(response).to redirect_to(root_path)
      end
    end

    context '誤った認証情報の場合' do
      it 'ログインできないこと' do
        post user_session_path, params: {
          user: { email: user.email, password: 'wrongpassword' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /users/sign_out' do
    let(:user) { create(:user) }
    before { sign_in user }

    it 'ログアウトできる' do
      delete destroy_user_session_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
