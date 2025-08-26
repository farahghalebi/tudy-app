class CreateJournals < ActiveRecord::Migration[7.1]
  def change
    create_table :journals do |t|
      t.string :title
      t.string :content
      t.text :summary
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
