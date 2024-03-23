class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :psp, limit: 255, default: "deferred", null: false
      t.string :country_code, limit: 255, default: "", null: false
      t.string :currency, limit: 3, default: "", null: false
      t.integer :total_amount, default: 0, null: false
      t.boolean :paid, default: false, null: false
      t.boolean :canceled, default: false, null: false
      t.string :email, limit: 255
      t.string :first_name, limit: 255, default: "", null: false
      t.string :last_name, limit: 255, default: "", null: false
      t.string :address1, limit: 255, default: "", null: false
      t.string :address2, limit: 255
      t.string :city, limit: 255, default: "", null: false
      t.string :zone, limit: 255
      t.string :postal_code, limit: 255, default: "", null: false
      t.uuid :token, null: false, index: {name: "orders_token_index", unique: true}
      t.string :stripe_session_id, limit: 255
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
