class Api::V1::MetricsController < ApplicationController
  def create
    category = Category.find_or_create_by(name: params[:category_name]) do |cat|
      cat.label = params[:category_name]
    end

    value_str = params[:value].to_s
    if value_str.start_with?('$', '¥', '€')
      unit = value_str[0]
      numeric_value = value_str[1..-1].gsub(/[^0-9.]/, '').to_f
      prefix_unit = true
    else
      unit = value_str.gsub(/[0-9.]/, '').strip
      numeric_value = value_str.gsub(/[^0-9.]/, '').to_f
      prefix_unit = false
    end

    metric = category.metrics.find_by(name: params[:metric_name])
    
    if metric.nil?
      metric = category.metrics.create!(
        name: params[:metric_name],
        label: params[:metric_name],
        unit: unit,
        prefix_unit: prefix_unit
      )
    else
      if metric.unit != unit || metric.prefix_unit != prefix_unit
        return render json: { error: 'メトリックの単位が一致しません' }, status: :unprocessable_entity
      end
    end

    # メトリック値を保存
    metric_value = metric.metric_values.create!(
      value: numeric_value,
      recorded_at: Time.current
    )

    render json: {
      category: category.name,
      metric: metric.name,
      value: numeric_value,
      unit: metric.unit,
      recorded_at: metric_value.recorded_at
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
