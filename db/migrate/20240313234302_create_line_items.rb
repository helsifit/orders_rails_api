class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.references :order, null: false, foreign_key: {on_delete: :restrict}, index: true
      t.string :product_variant_key, limit: 255, default: "unset", null: false
      t.integer :unit_amount, default: 0, null: false
      t.integer :quantity, default: 1, null: false
    end
  end
end
