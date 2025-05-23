# frozen_string_literal: true

class MetricsController < ApplicationController
  def index
    category = Category.find_by!(name: params[:category_name].downcase)
    metrics = category.metrics.includes(:metric_values).order(id: :desc)

    render json: {
      metrics: metrics.map do |metric|
        {
          name: metric.name,
          label: metric.label,
          values: metric.metric_values.map do |value|
            {
              value: value.value,
              value_with_unit: value.value_with_unit(prefix: metric.prefix_unit),
              recorded_at: value.recorded_at
            }
          end
        }
      end
    }
  end

  def update
    category = Category.find_or_create_by!(name: params[:category_name].downcase) do |cat|
      cat.label = params[:category_name].downcase
    end

    metric = Metric.create_with_value!(category, params[:metric_name], params[:value])

    render json: {
      category: {
        name: category.name,
        label: category.label,
        metric: {
          name: metric.name,
          label: metric.label,
          value: {
            value: metric.metric_values.last.value,
            value_with_unit: metric.metric_values.last.value_with_unit(prefix: metric.prefix_unit),
            recorded_at: metric.metric_values.last.recorded_at
          }
        }
      }
    }, status: :created
  end
end
