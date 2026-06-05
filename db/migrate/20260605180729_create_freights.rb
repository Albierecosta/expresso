class CreateFreights < ActiveRecord::Migration[8.0]
  def change
    create_table :freights do |t|
      t.references :client,    null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.references :driver, foreign_key: { to_table: :users }

      t.string  :code,         null: false
      t.string  :public_token, null: false
      t.string  :status,       null: false, default: "pending"
      t.decimal :amount,       null: false, precision: 10, scale: 2
      t.string  :order_number
      t.text    :notes

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :freights, :code,         unique: true
    add_index :freights, :public_token, unique: true
    add_index :freights, :status
  end
end
