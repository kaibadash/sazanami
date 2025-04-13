# frozen_string_literal: true

class AddDefaultToPrefixUnit < ActiveRecord::Migration[8.0]
  def up
    change_column_default :metrics, :prefix_unit, false
  end

  def down
    change_column_default :metrics, :prefix_unit, nil
  end
end
