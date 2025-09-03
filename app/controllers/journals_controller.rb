require "json"

class JournalsController < ApplicationController
  # ALL PROMTS in one Place here -------------------------------
  JOURNAL_APP_PROMT = "You are a personal journaling and to-do assistant."
  FILE_PROMT = "Extract the text from this file to create the journal entry.
                Output only the text form file (no extra text)"
  TITLE_PROMT = "TITLE_PROMT = "Generate a short, meaningful title (2–4 words) that captures the main theme or mood of the journal entry."
"
  SUMMARY_PROMT = "Create a short summary (1-2 sentences) reflecting the journal entry"
  # TAGS_PROMT = "Write 2–4 hashtags (e.g. Life, Work, Family, Love, ...)
              #  With very short content summaries extracted from the journal.
              # As valid JSON in this format: [{name: 'tag', content: 'summary'}]"
  TODOS_PROMT = "From my journal, extract actionable tasks that are NOT already completed.

INSTRUCTIONS:
1. Focus only on plans, intentions, or actions that still need to be done (future or pending tasks).
2. Do NOT create todos from activities already finished or written in the past tense.
3. Ignore anything that clearly indicates completion (e.g., 'I did', 'I finished', 'I went', 'I bought').
4. Keep todos concise and actionable.

OUTPUT FORMAT:
Return ONLY valid JSON, following this exact pattern:
[{title: 'groceries', description: 'buy ingredients for dinner'},
 {title: 'meditate', description: 'recover from hard work day'}]"
  # autocomplete prompt
  COMPLETED_TASKS_PROMT = "You are analyzing a journal entry to identify completed tasks from an existing to-do list.

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

  def new
    @journal = Journal.new
  end

  # Send Journal Input to AI and create Journal Entry in DB
  def create
    @journal = Journal.new(journal_params)
    @journal.user = current_user

    # Don’t call the LLM if the basic content is invalid
    unless @journal.valid?
      render :new, status: :unprocessable_entity
      return
    end

    if @journal.save
      redirect_to todos_path(journal_id: @journal.id), notice: "Journal created successfully."
    else
      render :new, status: :unprocessable_entity
    end


    # File Upload -----------------------------
    if @journal.file.attached?
      JournalFileJob.perform_later(@journal, JOURNAL_APP_PROMT, FILE_PROMT)
    else
      journal_text_jobs
    end


  end

  def show
    @journal = Journal.find(params[:id])
  end

  def index
    @journals = current_user.journals
  end

  # i did comment these out to have cleaner controller
  # def todo_brief
  # @journal = Journal.find(params[:id])
  # end

  private

  def journal_text_jobs
    # Title -------------------------------------
    JournalTitleJob.perform_later(@journal, JOURNAL_APP_PROMT, TITLE_PROMT)

    # TODO  --------------------------------
    JournalTodosJob.perform_later(@journal, JOURNAL_APP_PROMT, TODOS_PROMT)

    # Summary -----------------------------------
    JournalSummaryJob.perform_later(@journal, JOURNAL_APP_PROMT, SUMMARY_PROMT)

    # Auto-complete existing todos
    auto_complete_todos(@journal)
  end

  def journal_params
    params.require(:journal).permit(:content, :file)
  end

  # Auto-complete todos that are mentioned as done in the journal

  def auto_complete_todos(journal)
    begin
      # Get incomplete todos for this user
      incomplete_todos = journal.user.todos.where(status: false)
      return if incomplete_todos.empty?

      # Build context with journal and existing todos
      context = build_completion_context(journal, incomplete_todos)
      p "🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰"
      p context

      # Ask AI which todos are completed
      # RubyLLM.chat.with_instructions(journal_app_prompt).ask("#{title_prompt} #{journal.content}").content

      response = RubyLLM.chat.with_instructions(COMPLETED_TASKS_PROMT).ask(context).content
      return unless response.present?

      p "🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰"
      p response

      # Parse AI response and mark todos as completed
      parsed_response = JSON.parse(response)
      completed_ids = parsed_response["completed_todo_ids"] || []
      p parsed_response

      if completed_ids.any?
        # Find and mark todos as completed
        todos_to_complete = journal.user.todos.where(id: completed_ids, status: false)
        todos_to_complete.find_each do |todo|
          todo.update!(
            status: true,
            # completed_at: Time.current,
            #  auto_completed: true
          )
        end

        Rails.logger.info "Auto-completed #{todos_to_complete.count} todos for user #{journal.user.id}"
      end
    end
  end

  def build_completion_context(journal, todos)
    todos_list = todos.map do |todo|
      "ID: #{todo.id} | Title: #{todo.title} | Description: #{todo.description || 'No description'}"
    end.join("\n")

    context = <<~TEXT
      JOURNAL ENTRY:
      #{journal.content}

      EXISTING TO-DO LIST:
      #{todos_list}
    TEXT

    context
  end
end
