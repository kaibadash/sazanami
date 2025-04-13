# frozen_string_literal: true

class Metric < ApplicationRecord
  belongs_to :category
  has_many :metric_values, dependent: :destroy

  before_save -> { self.label = name if label.blank? }
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\-]+\z/ }
  validates :unit, presence: true
  validates :prefix_unit, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: :category_id }

  def self.create_with_value!(category, metric_name, value_str)
    numeric_value = nil
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

    metric.check_for_significant_change

    metric
  end

  private

  # NOTE: Slack通知を行っており、遅い処理になっている。非同期処理にするのか、チェック処理を定期バッチにするのが良いだろう。ここにこの処理を書くのも気持ち悪いし。
  def check_for_significant_change
    recent_values = metric_values.order(id: :desc).limit(10)
    return unless recent_values.size >= 2

    latest_value = recent_values.first
    previous_values = recent_values.drop(1)

    # 前回値がゼロに近い場合は通知しない（ゼロ除算回避と初期値からの変動を除外）
    previous_values.each do |prev_value|
      next if prev_value.value.abs < 0.0001

      change_percent = calculate_change_percent(prev_value.value, latest_value.value)

      next unless change_percent.abs >= ENV.fetch("METRIC_CHANGE_THRESHOLD", 20).to_f

      SlackNotifier::Client.notify_metric_change(
        self,
        prev_value.value,
        latest_value.value,
        change_percent
      )
      break
    end
  end

  def calculate_change_percent(old_value, new_value)
    ((new_value - old_value) / old_value.abs) * 100
  end
end
