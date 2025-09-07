# frozen_string_literal: true

class Metric < ApplicationRecord
  belongs_to :category
  has_many :metric_values, dependent: :destroy

  before_save :set_default_label

  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\-]+\z/ }
  validates :unit, presence: true
  validates :prefix_unit, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: :category_id }

  def self.create_with_value!(category, metric_name, value_str)
    unit = value_str.gsub(/[0-9,\-\.]/, "").strip

    if unit.present?
      numeric_value = value_str.gsub(unit, "").strip.to_f
      prefix_unit = value_str.start_with?(unit)
    else
      numeric_value = value_str.to_f
      prefix_unit = false
      unit = ""
    end

    metric = category.metrics.find_or_create_by!(name: metric_name) do |metric|
      metric.label = metric_name
      metric.unit = unit
      metric.prefix_unit = prefix_unit
    end

    metric.metric_values.create!(
      value: numeric_value,
      recorded_at: Time.current
    )

    metric
  end

  private

  def set_default_label
    self.label = name if label.blank?
  end
end
