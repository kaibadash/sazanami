# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MetricsController", type: :request do
  describe "GET /categories/:category_name/metrics" do
    let(:category) { create(:category, name: "aws", label: "Amazon Web Services") }
    let(:metric_rds) do
      create(:metric, category: category, name: "rds", label: "Database", unit: "$", prefix_unit: true)
    end

    before do
      create(:metric_value, metric: metric_rds, value: 1234.56, recorded_at: 2.days.ago)
      create(:metric_value, metric: metric_rds, value: 150.0, recorded_at: 1.day.ago)
    end

    context "when category exists" do
      before do
        get "/categories/#{category.name}/metrics"
      end

      it "returns all metrics with their values" do
        expect(response).to have_http_status(:ok)

        json_response = response.parsed_body
        expect(json_response["metrics"].length).to eq(1)

        rds_metric = json_response["metrics"].find { |m| m["name"] == "rds" }
        expect(rds_metric).to be_present
        expect(rds_metric["label"]).to eq(metric_rds.label)
        expect(rds_metric["values"].length).to eq(2)
        expect(rds_metric["values"].map { |v| v["value"] }).to contain_exactly("1234.56", "150.0")
        expect(rds_metric["values"].map { |v| v["value_with_unit"] }).to contain_exactly("$1,234.56", "$150.0")
      end
    end

    context "when category does not exist" do
      it "returns 404 error" do
        get "/categories/nonexistent-category/metrics"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PUT /categories/:category_name/metrics/:metric_name" do
    context "with valid parameters" do
      let(:category_name) { "aws" }
      let(:metric_name) { "rds" }
      let(:value) { "$1234.56" }

      before do
        put "/categories/#{category_name}/metrics/#{metric_name}", params: { value: value }
      end

      it "creates a new category and metric" do
        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["category"]["name"]).to eq(category_name)
        expect(json_response["category"]["metric"]["name"]).to eq(metric_name)
        expect(json_response["category"]["metric"]["value"]["value_with_unit"]).to eq("$1,234.56")
        expect(json_response["category"]["metric"]["value"]["value"]).to eq("1234.56")

        category = Category.find_by(name: category_name)
        expect(category).to be_present
        expect(category.name).to eq(category_name)
        expect(category.metrics.count).to eq(1)
        expect(category.metrics.first.name).to eq(metric_name)
        expect(category.metrics.first.unit).to eq("$")
        expect(category.metrics.first.metric_values.first.value).to eq(1234.56)
      end
    end
  end
end
