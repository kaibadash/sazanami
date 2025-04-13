class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :label, null: false, default: ""

      t.timestamps
    end
    add_index :categories, :name, unique: true
  end
end
