require "json"

class JournalsController < ApplicationController
  # ALL PROMTS in one Place here -------------------------------
  JOURNAL_APP_PROMT = "You are a personal journaling and to-do assistant. Rewrite the user's daily journal entry into a summary that feels self-written."
  TITLE_PROMT = "create a Title (2-4 words) capturing the day"
  SUMMARY_PROMT = "create a Summary (1-2 sentences) reflective and personal"
  TAGS_PROMT = "create 2-4 hashtags with super short summaries (example: #family - called mum, #work - need more focus, #health - did yoga, ...).
                As a valid JSON following this pattern: [{name: 'family', content: 'called mum'},{name: 'work', content: 'need more focus'},{name: 'health', content: 'did yoga'}]"
  TODOS_PROMT = " I  will write down my journal. From it, create a to-do list in valid JSON format.
                Instructions:
                Extract only actionable tasks.
                Each task must include:
                title: 1-3 words, concise
                description: short, actionable explanation
                Output only valid JSON (no extra text), following this pattern: [{title: 'groceries', description: 'cooking dinner for friends'},{title: 'meditate', description: 'recover from hard work day and finally give them back in order'}]"

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
      render :new
    end


    # Title -------------------------------------
    JournalTitleJob.perform_later(@journal, JOURNAL_APP_PROMT, TITLE_PROMT)

    # Summary -----------------------------------
    JournalSummaryJob.perform_later(@journal, JOURNAL_APP_PROMT, SUMMARY_PROMT)

    # Tags  -------------------------------------
    JournalTagsJob.perform_later(@journal, JOURNAL_APP_PROMT, TAGS_PROMT)

    # TODO_brief --------------------------------
    JournalTodosJob.perform_later(@journal, JOURNAL_APP_PROMT, TODOS_PROMT)

  end

  def show
    @journal = Journal.find(params[:id])
  end

  def todo_brief
    @journal = Journal.find(params[:id])
  end

  private

  def journal_params
    params.require(:journal).permit(:content)
  end
end
