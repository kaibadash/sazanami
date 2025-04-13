# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories", type: :request do
  describe "GET /categories" do
    let(:aws_category) { create(:category, name: "aws", label: "Amazon Web Services") }
    let(:gcp_category) { create(:category, name: "gcp", label: "Google Cloud Platform") }

    before do
      metric_rds = create(:metric, category: aws_category, name: "rds", label: "Database")
      create(:metric_value, metric: metric_rds, value: 150.0, recorded_at: 1.day.ago)
      metric_gce = create(:metric, category: gcp_category, name: "gce", label: "Compute Engine")
      create(:metric_value, metric: metric_gce, value: 200.0, recorded_at: 1.day.ago)
      metric_bigquery = create(:metric, category: gcp_category, name: "bigquery", label: "BigQuery")
      create(:metric_value, metric: metric_bigquery, value: 300.0, recorded_at: 1.day.ago)
    end

    it "returns all categories with their metrics count" do
      get "/categories"

      expect(response).to have_http_status(:ok)

      json_response = response.parsed_body
      expect(json_response["categories"].length).to eq(2)

      gcp = json_response["categories"].first
      expect(gcp).to be_present
      expect(gcp["label"]).to eq(gcp_category.label)
      expect(gcp["metrics_count"]).to eq(2)

      aws = json_response["categories"].second
      expect(aws).to be_present
      expect(aws["label"]).to eq(aws_category.label)
      expect(aws["metrics_count"]).to eq(1)
    end

    context "when no categories exist" do
      before do
        Category.destroy_all
      end

      it "returns an empty array" do
        get "/categories"

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["categories"]).to be_empty
      end
    end
  end
end
