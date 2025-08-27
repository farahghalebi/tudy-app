class MakeTagAssociationsOptional < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tags, :journal_id, true
    change_column_null :tags, :todo_id, true
  end
end
