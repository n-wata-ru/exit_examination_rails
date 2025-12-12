require 'rails_helper'

RSpec.describe "CoffeeBeans", type: :request do
  let!(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password') }
  let!(:coffee_bean) { CoffeeBean.create!(name: 'Test Bean') }

  before do
    post user_session_path, params: { user: { email: user.email, password: 'password' } }
  end

  describe "GET /index" do
    it "returns http success" do
      get coffee_beans_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_coffee_bean_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "redirects after deletion" do
      delete coffee_bean_path(coffee_bean)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(coffee_beans_path)
    end
  end
end
