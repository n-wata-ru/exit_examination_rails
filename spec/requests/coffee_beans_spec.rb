require 'rails_helper'

RSpec.describe "CoffeeBeans", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/coffee_beans/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/coffee_beans/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/coffee_beans/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/coffee_beans/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
