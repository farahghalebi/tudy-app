require "json"

class JournalsController < ApplicationController
  # ALL PROMTS in one Place here -------------------------------
  JOURNAL_APP_PROMT = "You are a personal journaling and to-do assistant."
  TITLE_PROMT = "Create a title (2-4 words) capturing the journal entry"
  SUMMARY_PROMT = "Create a short summary (1-2 sentences) reflecting the journal entry"
  TAGS_PROMT = "Create 2-4 hashtags with super short summaries (example: #family - called mum, #work - need more focus, #health - did yoga, ...).
                As a valid JSON following this pattern: [{name: 'family', content: 'called mum'},{name: 'work', content: 'need more focus'},{name: 'health', content: 'did yoga'}]"
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

    # Title & Summary -----------------------------------
    @journal.title = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{TITLE_PROMT} for this journal entry: #{@journal.content}").content
    @journal.summary = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{SUMMARY_PROMT} for this journal entry: #{@journal.content}").content

    @journal.user = current_user
    if @journal.save
      redirect_to todos_path(journal_id: @journal.id), notice: "Journal created successfully."
    else
      render :new
    end

    # Tags  -------------------------
    @tags_response = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{TAGS_PROMT} for this journal entry: #{@journal.content}").content
    @tags_json = JSON.parse(@tags_response)

    @tags_json.each do |tag|
      @tag = Tag.new
      @tag.name = tag["name"]
      @tag.content = tag["content"]
      @tag.journal_id = @journal.id
      @tag.save                           # ??? Should it have a safety: when save doesnt work ???
    end

    # TODO_brief - WIP (@David) ----------------------
    @todos_response = RubyLLM.chat.with_instructions(JOURNAL_APP_PROMT).ask("#{TODOS_PROMT} for this journal entry: #{@journal.content}").content
    @todos_json = JSON.parse(@todos_response)

    @todos_json.each do |todo|
      @todo = Todo.new
      @todo.title = todo["title"]
      @todo.description = todo["description"]
      @todo.status = false
      @todo.journal_id = @journal.id
      @todo.user_id = @journal.user_id
      @todo.save                        # ??? Should it have a safety: when save doesnt work ???
    end
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
