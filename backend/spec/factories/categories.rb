# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "category-#{n}" }
    sequence(:label) { |n| "Label #{n}" }
  end
end
