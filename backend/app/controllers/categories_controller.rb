# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    categories = Category.order(id: :desc).limit(100)

    render json: {
      categories: categories.map do |category|
        {
          name: category.name,
          label: category.label,
          metrics_count: category.metrics.count
        }
      end
    }
  end
end
