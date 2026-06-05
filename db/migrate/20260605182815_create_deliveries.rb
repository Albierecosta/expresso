class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries do |t|
      t.references :freight, null: false, foreign_key: true, index: { unique: true }
      t.text     :signature_svg
      t.string   :recipient_name
      t.datetime :delivered_at
      t.string   :ip_address
      t.text     :user_agent

      t.timestamps
    end
  end
end
