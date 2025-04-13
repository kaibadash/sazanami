require 'rails_helper'

RSpec.describe "Api::V1::Hellos", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe "GET /api/v1/hello" do
    it "returns a success response" do
      get "/api/v1/hello"
      expect(response).to have_http_status(:success)
    end

    it "returns the expected JSON response" do
      get "/api/v1/hello"
      json_response = JSON.parse(response.body)
      expect(json_response["message"]).to eq("Hello from Rails API!")
    end
  end
end
