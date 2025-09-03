class JournalAutoCompleteJob < ApplicationJob
  queue_as :default

  # Prompt for auto-completion
  COMPLETED_TASKS_PROMPT = "You are analyzing a journal entry to identify completed tasks from an existing to-do list.

INSTRUCTIONS:
1. Read the journal entry carefully
2. Look for activities that were ACTUALLY COMPLETED (past tense actions)
3. Match these activities with tasks from the existing to-do list
4. Only include tasks that have clear evidence of completion

COMPLETION INDICATORS:
- Past tense verbs: 'I did', 'I finished', 'I completed', 'I went', 'I bought', 'I called', 'I sent'
- Explicit statements: 'done', 'finished with', 'accomplished'
- Specific results: 'got the groceries', 'finished the report', 'met with John'

IMPORTANT RULES:
- Only match tasks that are clearly completed in the journal
- Be conservative - if unsure, don't mark as complete
- Consider partial matches (e.g., 'bought groceries' matches todo 'groceries')
- Ignore future plans or intentions

Return ONLY valid JSON in this exact format:
{\"completed_todo_ids\": [1, 3, 5]}

If no tasks are completed, return:
{\"completed_todo_ids\": []}"

  def perform(journal)
    return unless journal.present?

    begin
      # Get incomplete todos for this user
      incomplete_todos = journal.user.todos.where(status: false)
      return if incomplete_todos.empty?

      # Build context with journal and existing todos
      context = build_completion_context(journal, incomplete_todos)
      Rails.logger.info "Auto-completion context built for journal #{journal.id}"

      # Ask AI which todos are completed
      response = RubyLLM.chat.with_instructions(COMPLETED_TASKS_PROMPT).ask(context).content
      return unless response.present?

      Rails.logger.info "AI response received for journal #{journal.id}: #{response}"

      # Parse AI response and mark todos as completed
      parsed_response = JSON.parse(response)
      completed_ids = parsed_response["completed_todo_ids"] || []

      if completed_ids.any?
        # Find and mark todos as completed
        todos_to_complete = journal.user.todos.where(id: completed_ids, status: false)
        completion_count = 0

        todos_to_complete.find_each do |todo|
          if todo.update(status: true)
            completion_count += 1
            Rails.logger.info "Auto-completed todo #{todo.id}: #{todo.title}"
          end
        end

        Rails.logger.info "Auto-completed #{completion_count} todos for user #{journal.user.id}"

        # Optional: You could add a notification or callback here
        # NotifyUserJob.perform_later(journal.user, completion_count) if completion_count > 0
      else
        Rails.logger.info "No todos to auto-complete for journal #{journal.id}"
      end

    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse AI response for journal #{journal.id}: #{e.message}"
      Rails.logger.error "Response was: #{response}"
    rescue StandardError => e
      Rails.logger.error "Auto-completion job failed for journal #{journal.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end

  private

  def build_completion_context(journal, todos)
    todos_list = todos.map do |todo|
      "ID: #{todo.id} | Title: #{todo.title} | Description: #{todo.description || 'No description'}"
    end.join("\n")

    <<~TEXT
      JOURNAL ENTRY:
      #{journal.content}

      EXISTING TO-DO LIST:
      #{todos_list}
    TEXT
  end
end
