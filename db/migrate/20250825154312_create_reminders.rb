class CreateReminders < ActiveRecord::Migration[7.1]
  def change
    create_table :reminders do |t|
      t.references :todo, null: false, foreign_key: true
      t.interval :delay

      t.timestamps
    end
  end
end
