require 'rails_helper'

RSpec.describe "Homes", type: :request do
  let(:user) { create(:user) }

  describe "GET /home/index" do
    context 'ログイン済みの場合' do
      before { sign_in user, scope: :user }

      it "ホーム画面が表示される" do
        get "/home/index"
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
      end
    end

    context '未ログインの場合' do
      it "ログイン画面にリダイレクトされる" do
        get "/home/index"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
