require 'rails_helper'

RSpec.describe "Policies", type: :request do
  describe "GET /terms-of-service" do
    it "returns http success" do
      get "/policies/terms-of-service"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /privacy-policy" do
    it "returns http success" do
      get "/policies/privacy-policy"
      expect(response).to have_http_status(:success)
    end
  end
end
