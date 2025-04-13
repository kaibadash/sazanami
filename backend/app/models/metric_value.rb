# frozen_string_literal: true

class MetricValue < ApplicationRecord
  belongs_to :metric

  validates :value, presence: true, numericality: true
  validates :recorded_at, presence: true

  def value_with_unit(prefix)
    formatted_value = value.to_formatted_s(:delimited)
    
    return "#{metric.unit}#{formatted_value}" if prefix

    "#{formatted_value}#{metric.unit}"
  end
end
