# frozen_string_literal: true

require "rails_helper"

RSpec.describe Metric do
  describe "validations" do
    it "is valid with valid attributes" do
      metric = build(:metric)
      expect(metric).to be_valid
    end

    it "is not valid without a name" do
      metric = build(:metric, name: nil)
      expect(metric).not_to be_valid
    end

    it "is not valid with invalid name format" do
      metric = build(:metric, name: "invalid name")
      expect(metric).not_to be_valid
    end

    it "is not valid without prefix_unit" do
      metric = build(:metric, prefix_unit: nil)
      expect(metric).not_to be_valid
    end

    it "is not valid with duplicate name in same category" do
      category = create(:category)
      create(:metric, category: category, name: "test-metric")
      duplicate = build(:metric, category: category, name: "test-metric")
      expect(duplicate).not_to be_valid
    end

    it "is valid with same name in different category" do
      create(:metric, name: "test-metric")
      different_category = create(:category)
      duplicate = build(:metric, category: different_category, name: "test-metric")
      expect(duplicate).to be_valid
    end
  end

  describe "before_save callback" do
    it "sets label to name if label is blank" do
      metric = build(:metric, name: "test-metric", label: nil)
      metric.save
      expect(metric.label).to eq("test-metric")
    end

    it "does not change label if present" do
      metric = build(:metric, name: "test-metric", label: "Custom Label")
      metric.save
      expect(metric.label).to eq("Custom Label")
    end
  end

  describe ".create_with_value!" do
    let(:category) { create(:category) }

    context "with numeric value only" do
      it "creates metric and metric value" do
        metric = described_class.create_with_value!(category, "weight", "42.5")

        expect(metric.name).to eq("weight")
        expect(metric.unit).to eq("")
        expect(metric.prefix_unit).to be(false)

        expect(metric.metric_values.count).to eq(1)
        expect(metric.metric_values.first.value).to eq(42.5)
      end
    end

    context "with unit after value" do
      it "creates metric and metric value with unit" do
        metric = described_class.create_with_value!(category, "weight", "42.5 kg")

        expect(metric.name).to eq("weight")
        expect(metric.unit).to eq("kg")
        expect(metric.prefix_unit).to be(false)

        expect(metric.metric_values.count).to eq(1)
        expect(metric.metric_values.first.value).to eq(42.5)
      end
    end

    context "with unit before value" do
      it "creates metric and metric value with prefix unit" do
        metric = described_class.create_with_value!(category, "price", "$42.5")

        expect(metric.name).to eq("price")
        expect(metric.unit).to eq("$")
        expect(metric.prefix_unit).to be(true)

        expect(metric.metric_values.count).to eq(1)
        expect(metric.metric_values.first.value).to eq(42.5)
      end
    end

    context "when metric already exists" do
      let!(:existing_metric) { create(:metric, category: category, name: "weight", unit: "kg") }

      it "adds a new value to existing metric" do
        expect do
          described_class.create_with_value!(category, "weight", "50 kg")
        end.to change { existing_metric.metric_values.count }.by(1)

        expect(existing_metric.metric_values.last.value).to eq(50)
      end
    end
  end

  describe ".handle_on_significant_change" do
    let(:metric) { create(:metric) }

    before do
      allow(SlackNotifier::Client).to receive(:notify_metric_change)
    end

    context "with fewer than 3 values" do
      it "does not notify when there are fewer than 3 values" do
        create(:metric_value, metric: metric, value: 10)
        create(:metric_value, metric: metric, value: 12)

        described_class.handle_on_significant_change(metric)

        expect(SlackNotifier::Client).not_to have_received(:notify_metric_change)
      end
    end

    context "with significant change" do
      before do
        # 値を時系列の逆順で追加（最新が先頭になるように）
        create_list(:metric_value, 8, metric: metric, value: 10)
        create(:metric_value, metric: metric, value: 11) # 2番目の値
        create(:metric_value, metric: metric, value: 100) # 最新の値

        # Z-scoreの閾値を設定
        allow(ENV).to receive(:fetch).with("METRIC_Z_SCORE_THRESHOLD", 2.5).and_return(2.5)
      end

      it "notifies when there is a significant change" do
        described_class.handle_on_significant_change(metric)

        expect(SlackNotifier::Client).to have_received(:notify_metric_change).with(
          metric,
          kind_of(MetricValue),
          kind_of(MetricValue),
          kind_of(Numeric)
        )
      end
    end

    context "without significant change(z score 1.41)" do
      before do
        create_list(:metric_value, 3, metric: metric, value: 10)
        create(:metric_value, metric: metric, value: 10.1)
        create(:metric_value, metric: metric, value: 10.1) # target

        allow(ENV).to receive(:fetch).with("METRIC_Z_SCORE_THRESHOLD", 2.5).and_return(2.5)
      end

      it "does not notify when there is no significant change" do
        described_class.handle_on_significant_change(metric)

        expect(SlackNotifier::Client).not_to have_received(:notify_metric_change)
      end
    end
  end
end
