# frozen_string_literal: true

class MetricValue < ApplicationRecord
  belongs_to :metric

  validates :value, presence: true, numericality: true
  validates :recorded_at, presence: true
end
