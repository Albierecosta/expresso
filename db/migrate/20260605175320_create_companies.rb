class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name,       null: false
      t.string :legal_name
      t.string :cnpj,       null: false
      t.string :email
      t.string :phone

      t.timestamps
    end
    add_index :companies, :cnpj, unique: true
  end
end
