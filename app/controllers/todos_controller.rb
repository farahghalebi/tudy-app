# app/controllers/todos_controller.rb

class TodosController < ApplicationController
  before_action :set_todo, only: [:edit, :update, :destroy]

  PREDEFINED_CATEGORIES = ['Work', 'Personal', 'Health', 'Study', 'Finance', 'Leisure', 'Social', 'Hobbies', 'Development'].freeze


   def index
    todos_scope = find_todos_scope

    if params[:tag].present?
      # Filter by a specific tag
      # tag = Tag.find_by(name: params[:tag].capitalize)
      # @todos = tag ? tag.todos.order(status: :asc, due_date: :asc) : todos_scope.none
      @todos = todos_scope.joins(:tags).where(tags: { name: params[:tag] }).order(status: :asc, due_date: :asc)
    elsif params[:filter] == 'completed'
      # Filter by completed todos
      @todos = todos_scope.where(status: true).order(due_date: :desc)
    else
      # Default view: all todos, grouped by tags
      # as of now: to dos without tag, WONT BE SHOWN!!!
      @todos_by_tag = todos_scope.joins(:tags).includes(:tags).group_by { |todo| todo.tags.first.name }
      @todos_by_tag = @todos_by_tag.sort_by { |tag_name, _| tag_name }
    end

    @todo = Todo.new
  end

  def create
    @todo = find_todos_scope.build(todo_params)
    @todo.user = current_user
    @todo.status = false
    if @todo.save
      respond_to do |format|
        format.html { redirect_to todos_path, notice: 'To-do was successfully created.' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('new_todo_form', partial: "form", locals: { todo: @todo, journal: @journal })}
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    if @todo.update(todo_params)
      respond_to do |format|
        format.html { redirect_to todos_path }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@todo, partial: "form", locals: { todo: @todo }) }
      end
    end
  end

  def destroy
    todo_name = @todo.title # variable for the notification
    @todo.destroy
    respond_to do |format|
      format.html {redirect_to todos_path, status: :see_other, notice: "To-Do '#{todo_name}'was deleted"} # can be removed, if not wanted
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo) }
    end
  end

  private

  def find_todos_scope
    if params[:journal_id].present?
      @journal = current_user.journals.find(params[:journal_id])
      @journal.todos
    else
      current_user.todos
    end
  end

  def set_todo
    @todo = find_todos_scope.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :status)
  end
end
