class JournalTodosJob < ApplicationJob
  queue_as :default

  def perform(journal, journal_app_prompt, todos_prompt)
    # Do something later
    puts "🐰🐰🐰 Performing TODOS Job 🐰🐰🐰"
    todos_response = RubyLLM.chat
                            .with_instructions(journal_app_prompt)
                            .ask("#{todos_prompt} #{journal.content}")
                            .content
    todos_json = JSON.parse(todos_response)

    todos_json.each do |todo_json|
      todo = Todo.new
      todo.title = todo_json["title"]
      todo.description = todo_json["description"]
      todo.status = false
      todo.journal_id = journal.id
      todo.user_id = journal.user_id

      if todo.save
        puts "🐰🐰🐰 TODO: #{todo.title} 🐰🐰🐰"

        Turbo::StreamsChannel.broadcast_append_to(
          "journal_stream",
          target: "todos",
          partial: "todos/todo",
          locals: { todo: todo}
        )
      else
        puts "❌❌❌ Failed to save TODO: #{todo.errors.full_messages.join(", ")} ❌❌❌"
      end

    end

    puts "🐰🐰🐰 TODOS Job DONE 🐰🐰🐰"
  end
end
