require "json"

class JournalsController < ApplicationController
  # ALL PROMPTS in one place here -------------------------------
  JOURNAL_APP_PROMT = "You are a personal journaling and to-do assistant."
  FILE_PROMT = "Extract the text from this file to create the journal entry.
                Output only the text form file (no extra text)"
  TITLE_PROMT = "Generate a short, meaningful title (2–4 words) that captures the main theme or mood of the journal entry."

  SUMMARY_PROMT = "Create a short summary (1-2 sentences) reflecting the journal entry"

  TODOS_PROMT = "From my journal, extract actionable tasks into valid JSON. Each task must have:
                title: 1-3 words, concise
                description: extract a short text from journal
                Output only valid JSON (no extra text), following this pattern: [{title: 'groceries', description: 'cooking dinner for friends'},{title: 'meditate', description: 'recover from hard work day and finally give them back in order'}]"


  def new
    @journal = Journal.new
  end

  # Send Journal Input to AI and create Journal Entry in DB
  def create
    @journal = Journal.new(journal_params)
    @journal.user = current_user

    # Don't call the LLM if the basic content is invalid
    unless @journal.valid?
      render :new, status: :unprocessable_entity
      return
    end

    if @journal.save
      redirect_to todos_path(journal_id: @journal.id), notice: "Journal created successfully."
    else
      render :new, status: :unprocessable_entity
      return
    end

    # File Upload -----------------------------
    if @journal.file.attached?
      JournalFileJob.perform_later(@journal, JOURNAL_APP_PROMT, FILE_PROMT)
    else
      journal_text_jobs
    end
  end

  def show
    @journal = current_user.journals.find(params[:id])
  end

  def index
    @journals = current_user.journals
  end

  private

  def journal_text_jobs
    # Title -------------------------------------
    JournalTitleJob.perform_later(@journal, JOURNAL_APP_PROMT, TITLE_PROMT)

    # TODO  --------------------------------
    JournalTodosJob.perform_later(@journal, JOURNAL_APP_PROMT, TODOS_PROMT)

    # Summary -----------------------------------
    JournalSummaryJob.perform_later(@journal, JOURNAL_APP_PROMT, SUMMARY_PROMT)

    # Auto-complete existing todos (now as background job)
    JournalAutoCompleteJob.perform_later(@journal)
  end

  def journal_params
    params.require(:journal).permit(:content, :file)
  end
end
