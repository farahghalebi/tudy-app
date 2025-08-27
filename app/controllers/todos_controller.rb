class TodosController < ApplicationController
  def index
    @todos = Todo.where(journal_id: params[:journal_id])
  end
end
