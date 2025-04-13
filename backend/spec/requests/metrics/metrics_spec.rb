# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MetricsController", type: :request do
  describe "PUT /categories/:category_name/metrics/:metric_name" do
    context "with valid parameters" do
      let(:category_name) { "aws" }
      let(:metric_name) { "rds" }
      let(:value) { "$123.45" }

      before do
        put "/categories/#{category_name}/metrics/#{metric_name}", params: { value: value }
      end

      it "creates a new category and metric" do
        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["category"]["name"]).to eq(category_name)
        expect(json_response["category"]["metric"]["name"]).to eq(metric_name)
        expect(json_response["category"]["metric"]["unit"]).to eq("$")
        expect(json_response["category"]["metric"]["value"]["value"]).to eq("123.45")

        category = Category.find_by(name: category_name)
        expect(category).to be_present
        expect(category.name).to eq(category_name)
        expect(category.metrics.count).to eq(1)
        expect(category.metrics.first.name).to eq(metric_name)
        expect(category.metrics.first.unit).to eq("$")
        expect(category.metrics.first.metric_values.first.value).to eq(123.45)
      end
    end
  end
end
