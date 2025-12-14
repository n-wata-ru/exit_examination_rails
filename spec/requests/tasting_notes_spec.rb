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
    it "returns http success" do
      get tasting_notes_path
      expect(response).to have_http_status(:success)
    end

    it "only shows current user's tasting notes" do
      get tasting_notes_path
      expect(response.body).to include(coffee_bean.name)
      expect(response.body).not_to include(other_coffee_bean.name)
    end
  end

  describe "GET /show" do
    it "returns http success for own tasting note" do
      get tasting_note_path(tasting_note)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for other user's tasting note" do
      get tasting_note_path(other_tasting_note)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "returns http success for own coffee bean" do
      get new_coffee_bean_tasting_note_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for other user's coffee bean" do
      get new_coffee_bean_tasting_note_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a tasting note for current user's coffee bean" do
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

      it "associates tasting note with current user" do
        post coffee_bean_tasting_notes_path(coffee_bean), params: {
          tasting_note: { preference_score: 5 }
        }
        expect(TastingNote.last.user).to eq(user)
      end
    end

    context "with invalid parameters" do
      it "does not create a tasting note with invalid score" do
        expect {
          post coffee_bean_tasting_notes_path(coffee_bean), params: {
            tasting_note: { preference_score: 10 }
          }
        }.not_to change(TastingNote, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "for other user's coffee bean" do
      it "returns 404" do
        post coffee_bean_tasting_notes_path(other_coffee_bean), params: {
          tasting_note: { preference_score: 5 }
        }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /edit" do
    it "returns http success for own tasting note" do
      get edit_coffee_bean_tasting_note_path(coffee_bean, tasting_note)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for other user's tasting note" do
      get edit_coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when accessing own tasting note through other user's coffee bean path" do
      get edit_coffee_bean_tasting_note_path(other_coffee_bean, tasting_note)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates own tasting note" do
        patch coffee_bean_tasting_note_path(coffee_bean, tasting_note), params: {
          tasting_note: { preference_score: 4 }
        }
        expect(tasting_note.reload.preference_score).to eq(4)
        expect(response).to redirect_to(tasting_note_path(tasting_note))
      end
    end

    context "with invalid parameters" do
      it "does not update tasting note" do
        original_score = tasting_note.preference_score
        patch coffee_bean_tasting_note_path(coffee_bean, tasting_note), params: {
          tasting_note: { preference_score: 10 }
        }
        expect(tasting_note.reload.preference_score).to eq(original_score)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "for other user's tasting note" do
      it "returns 404" do
        patch coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note), params: {
          tasting_note: { preference_score: 1 }
        }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes own tasting note" do
      expect {
        delete coffee_bean_tasting_note_path(coffee_bean, tasting_note)
      }.to change(TastingNote, :count).by(-1)
      expect(response).to redirect_to(coffee_bean_path(coffee_bean))
    end

    it "returns 404 for other user's tasting note" do
      delete coffee_bean_tasting_note_path(other_coffee_bean, other_tasting_note)
      expect(response).to have_http_status(:not_found)
    end

    it "does not delete other user's tasting note" do
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

    it "redirects to login when not authenticated" do
      get tasting_notes_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
