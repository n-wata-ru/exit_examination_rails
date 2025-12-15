require 'rails_helper'

RSpec.describe "TastingNotes", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user) }
  let!(:coffee_bean) { FactoryBot.create(:coffee_bean, user: user) }
  let!(:other_coffee_bean) { FactoryBot.create(:coffee_bean, user: other_user, name: 'Other Bean') }
  let!(:tasting_note) { TastingNote.create!(user: user, coffee_bean: coffee_bean, preference_score: 5) }
  let!(:other_tasting_note) { TastingNote.create!(user: other_user, coffee_bean: other_coffee_bean, preference_score: 3) }

  before do
    post user_session_path, params: { user: { email: user.email, password: 'password123' } }
  end

  describe "GET /index" do
    it "一覧ページを取得できること" do
      get tasting_notes_path
      expect(response).to have_http_status(:success)
    end

    it "現在のユーザーのテイスティングノートのみ表示されること" do
      get tasting_notes_path
      expect(response.body).to include(coffee_bean.name)
      expect(response.body).not_to include(other_coffee_bean.name)
    end
  end

  describe "GET /show" do
    it "自身のテイスティングノートの詳細を取得できること" do
      get tasting_note_path(tasting_note)
      expect(response).to have_http_status(:success)
    end

    it "他のユーザーのテイスティングノートの場合は404 Not Foundを返すこと" do
      get tasting_note_path(other_tasting_note)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "コーヒー豆のテイスティングノート作成ページを取得できること" do
      get new_coffee_bean_tasting_note_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end

    it "所有していないコーヒー豆を評価はできないため、404 Not Foundを返すこと" do
      get new_coffee_bean_tasting_note_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    context "有効なパラメータの場合" do
      it "現在のユーザーのコーヒー豆に対してテイスティングノートを作成できること" do
        expect {
          post coffee_bean_tasting_notes_path(coffee_bean), params: {
            tasting_note: {
              preference_score: 4,
              acidity_score: 3,
              bitterness_score: 2,
              sweetness_score: 5,
              brew_method: 'ハンドドリップ'
            }
          }
        }.to change(TastingNote, :count).by(1)

        expect(response).to redirect_to(coffee_bean_path(coffee_bean))
      end

      it "作成したテイスティングノートが現在のユーザーと関連付けられること" do
        post coffee_bean_tasting_notes_path(coffee_bean), params: {
          tasting_note: { preference_score: 5 }
        }
        expect(TastingNote.last.user).to eq(user)
      end
    end

    context "無効なパラメータの場合" do
      it "無効なスコアでテイスティングノートを作成できないこと" do
        expect {
          post coffee_bean_tasting_notes_path(coffee_bean), params: {
            tasting_note: { preference_score: 10 }
          }
        }.not_to change(TastingNote, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "所有していないコーヒー豆の場合" do
      it "404 Not Foundを返すこと" do
        post coffee_bean_tasting_notes_path(other_coffee_bean), params: {
          tasting_note: { preference_score: 5 }
        }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /edit" do
    it "自身のテイスティングノートの編集ページを取得できること" do
      get edit_coffee_bean_tasting_note_path(coffee_bean, tasting_note)
      expect(response).to have_http_status(:success)
    end

    it "他のユーザーのテイスティングノートの場合は404 Not Foundを返すこと" do
      get edit_coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note)
      expect(response).to have_http_status(:not_found)
    end

    it "自身のテイスティングノートを他のユーザーのコーヒー豆のパスからアクセスした場合は404 Not Foundを返すこと" do
      get edit_coffee_bean_tasting_note_path(other_coffee_bean, tasting_note)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "自身のテイスティングノートを更新できること" do
        patch coffee_bean_tasting_note_path(coffee_bean, tasting_note), params: {
          tasting_note: { preference_score: 4 }
        }
        expect(tasting_note.reload.preference_score).to eq(4)
        expect(response).to redirect_to(tasting_note_path(tasting_note))
      end
    end

    context "無効なパラメータの場合" do
      it "テイスティングノートを更新できないこと" do
        original_score = tasting_note.preference_score
        patch coffee_bean_tasting_note_path(coffee_bean, tasting_note), params: {
          tasting_note: { preference_score: 10 }
        }
        expect(tasting_note.reload.preference_score).to eq(original_score)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "所有していないテイスティングノートの場合" do
      it "404 Not Foundを返すこと" do
        patch coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note), params: {
          tasting_note: { preference_score: 1 }
        }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    it "自身のテイスティングノートを削除できること" do
      expect {
        delete coffee_bean_tasting_note_path(coffee_bean, tasting_note)
      }.to change(TastingNote, :count).by(-1)
      expect(response).to redirect_to(coffee_bean_path(coffee_bean))
    end

    it "他のユーザーのテイスティングノートの場合は404 Not Foundを返すこと" do
      delete coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note)
      expect(response).to have_http_status(:not_found)
    end

    it "他のユーザーのテイスティングノートを削除できないこと" do
      expect {
        delete coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note)
      }.not_to change(TastingNote, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "authentication" do
    before do
      delete destroy_user_session_path
    end

    it "認証されていない場合はログインページにリダイレクトされること" do
      get tasting_notes_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
