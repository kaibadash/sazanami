# frozen_string_literal: true

FactoryBot.define do
  factory :metric_value do
    metric
    value { 42.5 }
    recorded_at { Time.current }
  end
end
