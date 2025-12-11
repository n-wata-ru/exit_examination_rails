require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  describe 'GET /users/sign_up' do
    it '新規登録動線が表示されること' do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("新規登録")
    end
  end

  describe 'POST /users' do
    context '有効なパラメータの場合' do
      let(:valid_params) do
        {
          user: {
            name: 'testuser',
            email: 'testuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it '新規登録できること' do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(root_path)
      end
    end

    context '無効なパラメータの場合' do
      let(:invalid_params) do
        {
          user: {
            email: 'testuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it '新規登録できないこと' do
        expect {
          post user_registration_path, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
