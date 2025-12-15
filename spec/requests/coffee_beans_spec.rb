require 'rails_helper'

RSpec.describe "CoffeeBeans", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user) }
  let!(:coffee_bean) { FactoryBot.create(:coffee_bean, user: user) }
  let!(:other_coffee_bean) { FactoryBot.create(:coffee_bean, user: other_user, name: 'Other Bean') }

  before do
    post user_session_path, params: { user: { email: user.email, password: 'password123' } }
  end

  describe "GET /index" do
    it "コーヒー豆一覧を取得できること" do
      get coffee_beans_path
      expect(response).to have_http_status(:success)
    end

    it "現在のユーザーのコーヒー豆のみ取得されること" do
      get coffee_beans_path
      expect(response.body).to include(coffee_bean.name)
      expect(response.body).not_to include(other_coffee_bean.name)
    end
  end

  describe "GET /show" do
    it "自身のコーヒー豆の詳細を取得できること" do
      get coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end

    it "他のユーザーのコーヒー豆の場合は404 Not Foundを返すこと" do
      get coffee_bean_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "新しいコーヒー豆の作成ページを取得できること" do
      get new_coffee_bean_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "コーヒー豆を作成できること" do
      expect {
        post coffee_beans_path, params: { coffee_bean: { name: 'New Bean' } }
      }.to change(user.coffee_beans, :count).by(1)
    end

    context "with image attachment" do
      it "コーヒー豆を画像付きで作成できること" do
        file = fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg')

        expect {
          post coffee_beans_path, params: {
            coffee_bean: { name: 'Image Bean', image: file }
          }
        }.to change(user.coffee_beans, :count).by(1)

        expect(user.coffee_beans.last.image).to be_attached
        expect(response).to redirect_to(coffee_beans_path)
      end

      it "画像なしでも作成できること" do
        expect {
          post coffee_beans_path, params: {
            coffee_bean: { name: 'No Image Bean' }
          }
        }.to change(user.coffee_beans, :count).by(1)

        expect(user.coffee_beans.last.image).not_to be_attached
      end
    end
  end

  describe "GET /edit" do
    it "自身のコーヒー豆の編集ページを取得できること" do
      get edit_coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end

    it "他のユーザーのコーヒー豆の場合は404 Not Foundを返すこと" do
      get edit_coffee_bean_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /update" do
    it "自身のコーヒー豆を更新できること" do
      patch coffee_bean_path(coffee_bean), params: { coffee_bean: { name: 'Updated Bean' } }
      expect(coffee_bean.reload.name).to eq('Updated Bean')
    end

    it "他のユーザーのコーヒー豆の場合は404 Not Foundを返すこと" do
      patch coffee_bean_path(other_coffee_bean), params: { coffee_bean: { name: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end

    context "with image update" do
      it "既存のコーヒー豆に画像を追加できること" do
        file = fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg')

        patch coffee_bean_path(coffee_bean), params: {
          coffee_bean: { image: file }
        }

        expect(coffee_bean.reload.image).to be_attached
        expect(response).to redirect_to(coffee_bean_path(coffee_bean))
      end

      it "画像を変更できること" do
        # 最初の画像を添付
        coffee_bean.image.attach(
          io: File.open('spec/fixtures/files/test_image.jpg'),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )

        # 新しい画像に変更
        new_file = fixture_file_upload('spec/fixtures/files/new_image.jpg', 'image/jpeg')
        patch coffee_bean_path(coffee_bean), params: {
          coffee_bean: { image: new_file }
        }

        expect(coffee_bean.reload.image).to be_attached
        expect(coffee_bean.image.filename.to_s).to eq('new_image.jpg')
      end
    end
  end

  describe "DELETE /destroy" do
    it "自身のコーヒー豆を削除できること" do
      expect {
        delete coffee_bean_path(coffee_bean)
      }.to change(CoffeeBean, :count).by(-1)
      expect(response).to redirect_to(coffee_beans_path)
    end

    it "他のユーザーのコーヒー豆の場合は404 Not Foundを返すこと" do
      delete coffee_bean_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end

    context "with attached image" do
      it "コーヒー豆削除時に関連する画像も削除されること" do
        # 画像を添付
        coffee_bean.image.attach(
          io: File.open('spec/fixtures/files/test_image.jpg'),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )

        expect(coffee_bean.image).to be_attached

        # Active Storage Blobsの数を確認
        expect {
          delete coffee_bean_path(coffee_bean)
        }.to change(ActiveStorage::Attachment, :count).by(-1)

        expect(response).to redirect_to(coffee_beans_path)
      end
    end
  end
end
