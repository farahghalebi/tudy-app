# app/controllers/todos_controller.rb

class TodosController < ApplicationController
  before_action :set_todo, only: [:destroy]

  def index
    if params[:journal_id]
      @todos = Todo.where(journal_id: params[:journal_id])
    else
      @todos = Todo.all
    end
  end

  def destroy
    todo_name = @todo.title # variable for the notification
    @todo.destroy
    redirect_to todos_path, status: :see_other, notice: "To-Do '#{todo_name}'was deleted" # can be removed, if not wanted
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end
end
