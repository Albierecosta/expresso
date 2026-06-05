class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name,     null: false
      t.string :document
      t.string :email
      t.string :phone
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
