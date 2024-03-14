class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.uuid :token, null: false, index: {unique: true}
      t.string :psp, null: false
      t.string :country_code, null: false
      t.string :email
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :address1, null: false
      t.string :address2
      t.string :city, null: false
      t.string :zone
      t.string :postal_code, null: false
      t.string :currency, null: false, limit: 7
      t.integer :total_amount
      t.boolean :paid, default: false, null: false
      t.boolean :canceled, default: false, null: false
      t.string :stripe_session_id

      t.timestamps
    end
  end
end
