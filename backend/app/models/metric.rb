# frozen_string_literal: true

class Metric < ApplicationRecord
  belongs_to :category
  has_many :metric_values, dependent: :destroy

  before_save -> { self.label = name if label.blank? }
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\-]+\z/ }
  validates :prefix_unit, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: :category_id }

  def self.create_with_value!(category, metric_name, value_str)
    unit = value_str.gsub(/[0-9,\-\.]/, "").strip
    prefix_unit = false
    if unit.present?
      numeric_value = value_str.gsub(unit, "").strip.to_f
      prefix_unit = value_str.start_with?(unit)
    else
      numeric_value = value_str.to_f
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

    handle_on_significant_change(metric)

    metric
  end

  # NOTE: Slack通知を行っており、遅い処理になっている。非同期処理にするのか、チェック処理を定期バッチにするのが良いだろう。ここにこの処理を書くのも気持ち悪いし。
  def self.handle_on_significant_change(metric)
    recent_values = metric.metric_values.order(id: :desc).limit(10)
    return unless recent_values.size >= 3

    z_score = Statistics.z_score(recent_values.first.value, recent_values.drop(1).map(&:value))
    return unless z_score.abs > ENV.fetch("METRIC_Z_SCORE_THRESHOLD", 2.5).to_f

    SlackNotifier::Client.notify_metric_change(
      metric,
      recent_values.second,
      recent_values.first,
      z_score
    )
  end
end
