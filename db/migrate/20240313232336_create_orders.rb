class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :psp, default: "deferred", null: false
      t.string :country_code, default: "", null: false
      t.string :currency, default: "", null: false, limit: 7
      t.integer :total_amount, default: 0, null: false
      t.boolean :paid, default: false, null: false
      t.boolean :canceled, default: false, null: false
      t.string :email
      t.string :first_name, default: "", null: false
      t.string :last_name, default: "", null: false
      t.string :address1, default: "", null: false
      t.string :address2
      t.string :city, default: "", null: false
      t.string :zone
      t.string :postal_code, default: "", null: false
      t.uuid :token, null: false, index: {unique: true}
      t.string :stripe_session_id
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
