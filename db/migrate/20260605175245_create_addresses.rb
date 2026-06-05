class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string  :street,       null: false
      t.string  :number
      t.string  :complement
      t.string  :neighborhood
      t.string  :city,         null: false
      t.string  :state,        null: false, limit: 2
      t.string  :zipcode,      null: false
      t.references :addressable, polymorphic: true, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
