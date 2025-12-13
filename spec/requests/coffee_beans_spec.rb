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
    it "returns http success" do
      get coffee_beans_path
      expect(response).to have_http_status(:success)
    end

    it "only shows current user's coffee beans" do
      get coffee_beans_path
      expect(response.body).to include(coffee_bean.name)
      expect(response.body).not_to include(other_coffee_bean.name)
    end
  end

  describe "GET /show" do
    it "returns http success for own coffee bean" do
      get coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for other user's coffee bean" do
      get coffee_bean_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_coffee_bean_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a coffee bean for current user" do
      expect {
        post coffee_beans_path, params: { coffee_bean: { name: 'New Bean' } }
      }.to change(user.coffee_beans, :count).by(1)
    end
  end

  describe "GET /edit" do
    it "returns http success for own coffee bean" do
      get edit_coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for other user's coffee bean" do
      get edit_coffee_bean_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /update" do
    it "updates own coffee bean" do
      patch coffee_bean_path(coffee_bean), params: { coffee_bean: { name: 'Updated Bean' } }
      expect(coffee_bean.reload.name).to eq('Updated Bean')
    end

    it "returns 404 for other user's coffee bean" do
      patch coffee_bean_path(other_coffee_bean), params: { coffee_bean: { name: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /destroy" do
    it "deletes own coffee bean" do
      expect {
        delete coffee_bean_path(coffee_bean)
      }.to change(CoffeeBean, :count).by(-1)
      expect(response).to redirect_to(coffee_beans_path)
    end

    it "returns 404 for other user's coffee bean" do
      delete coffee_bean_path(other_coffee_bean)
      expect(response).to have_http_status(:not_found)
    end
  end
end
