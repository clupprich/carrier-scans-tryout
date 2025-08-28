class CreateTrackingEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :tracking_events do |t|
      t.string :source_id, null: false
      t.string :status, null: false
      t.string :carrier, null: false
      t.text :message, null: false
      t.datetime :pushed_at, null: true
      t.string :tracking_number, null: false
      t.text :payload, null: false, default: "{}"

      t.timestamps
    end

    add_index :tracking_events, :carrier
    add_index :tracking_events, :status
    add_index :tracking_events, :tracking_number
  end
end
