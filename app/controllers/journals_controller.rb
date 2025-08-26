class JournalsController < ApplicationController
  SYSTEM_PROMT = "You are a personal journaling and to-do assistant.
  Rewrite the user’s daily journal entry into a summary that feels self-written."

  def new
    @journal = Journal.new
  end

  # 3) Insights with hashtags + short notes (2-3 words),
  # 4) To-Do list (optional, prioritized, concise, with emojis).

  # Send Journal Input to AI and create Journal Entry in DB
  def create
    @journal = Journal.new(journal_params)

    # Title -----------------------------------
    @journal.title = RubyLLM.chat.with_instructions(SYSTEM_PROMT).ask("create a Title (2–4 words) capturing the day for this journal entry: #{@journal.content}").content

    # Summary ---------------------------------
    @journal.summary = RubyLLM.chat.with_instructions(SYSTEM_PROMT).ask("create a Summary (1-2 sentences) reflective and personal for this journal entry: #{@journal.content}").content

    # Tags
    @tags = RubyLLM.chat.with_instructions(SYSTEM_PROMT).ask("create 2-4 hashtags (like: #family, friendship, #work, #health, ...) for this journal entry: #{@journal.content}").content
    # TODOs -----------------------------------

    @journal.user = current_user
    if @journal.save
      redirect_to journal_path(@journal), notice: "Journal created successfully."
    else
      render :new
    end
  end

  def show
    @journal = Journal.find(params[:id])
  end

  private

  def journal_params
    params.require(:journal).permit(:content)
  end
end
