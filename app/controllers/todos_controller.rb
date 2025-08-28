# app/controllers/todos_controller.rb

class TodosController < ApplicationController
  before_action :set_todo, only: [:edit, :update, :destroy]

  def index
    if params[:journal_id]
      @journal = current_user.journals.find(params[:journal_id])
      @todos = @journal.todos.order(status: :asc, due_date: :asc)
    else
      @todos = current_user.todos.all.order(status: :asc, due_date: :asc)
    end
  end

  def edit
  end

  def update
    @todo.update(todo_params)

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to todos_path }
    end
  end

  def destroy
    todo_name = @todo.title # variable for the notification
    @todo.destroy
    redirect_to todos_path, status: :see_other, notice: "To-Do '#{todo_name}'was deleted" # can be removed, if not wanted
  end

def completed
  if params[:journal_id]
    @journal = current_user.journals.find(params[:journal_id])
    @todos = @journal.todos.where(status: true).order(due_date: :desc)
  else
    @todos = current_user.todos.where(status: true).order(due_date: :desc)
  end
end

  private

  def set_todo
  @todo = current_user.todos.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :status)
  end
end
