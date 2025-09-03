class AddNullTrueToTodos < ActiveRecord::Migration[7.1]
  def change
    change_column_null :todos, :journal_id, true
  end
end
