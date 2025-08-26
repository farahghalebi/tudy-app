require "json"

class JournalsController < ApplicationController
  JOURNAL_APP_PROMT = "You are a personal journaling and to-do assistant. Rewrite the user's daily journal entry into a summary that feels self-written."
  TITLE_PROMT = "create a Title (2-4 words) capturing the day"
  SUMMARY_PROMT = "create a Summary (1-2 sentences) reflective and personal"
  TAGS_PROMT = "create 2-4 hashtags with super short summaries (example: #family - called mum, #work - need more focus, #health - did yoga, ...)
  as a valid JSON following this pattern: [{name: 'family', content: 'called mum'},{name: 'work', content: 'need more focus'},{name: 'health', content: 'did yoga'}]"
  TODOS_PROMT = " create a To-Do list (prioritized, concise, with emojis)"

  def new
    @journal = Journal.new
  end

  # Send Journal Input to AI and create Journal Entry in DB
  def create
    @journal = Journal.new(journal_params)

    # Title -----------------------------------
    @journal.title = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{TITLE_PROMT} for this journal entry: #{@journal.content}").content
    # Summary ---------------------------------
    @journal.summary = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{SUMMARY_PROMT} for this journal entry: #{@journal.content}").content

    @journal.user = current_user
    if @journal.save
      redirect_to journal_todo_brief_path(@journal), notice: "Journal created successfully."
    else
      render :new
    end

    # Tags  - WIP (@David)
    @tags_response = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{TAGS_PROMT} for this journal entry: #{@journal.content}").content
    @tags = JSON.parse(@tags_response)
    raise

    # TODO_brief - WIP (@David)
    @todo_brief = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{TODOS_PROMT} for this journal entry: #{@journal.content}").content
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
