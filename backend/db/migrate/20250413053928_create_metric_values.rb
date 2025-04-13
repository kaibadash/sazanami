# frozen_string_literal: true

class CreateMetricValues < ActiveRecord::Migration[8.0]
  def change
    create_table :metric_values do |t|
      t.references :metric, null: false, foreign_key: true
      t.decimal :value, precision: 15, scale: 2, null: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end
  end
end
