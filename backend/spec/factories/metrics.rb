# frozen_string_literal: true

FactoryBot.define do
  factory :metric do
    category
    sequence(:name) { |n| "metric-#{n}" }
    sequence(:label) { |n| "Metric #{n}" }
    unit { "kg" }
    prefix_unit { false }
  end
end
