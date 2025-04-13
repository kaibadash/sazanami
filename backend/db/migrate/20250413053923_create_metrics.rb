# frozen_string_literal: true

class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :label, null: false, default: ""
      t.string :unit, null: false
      t.boolean :prefix_unit, null: false, default: false

      t.timestamps
    end

    add_index :metrics, %i[category_id name], unique: true
  end
end
