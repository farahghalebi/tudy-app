class JournalsController < ApplicationController
  def new
    @journal = Journal.new
  end

  def create

    @journal = Journal.new(journal_params)
    # -> ask the AI here
    @journal.title = RubyLLM.chat.ask("create a 2-5 world title for this journal entry: #{@journal.content}").content
    @journal.summary = RubyLLM.chat.ask("create a 2 sentence summary for this journal entry: #{@journal.content}").content
    @journal.user = current_user
    if @journal.save
      redirect_to root_path, notice: "Journal created successfully."
    else
      render :new
    end
  end

  private

  def journal_params
    params.require(:journal).permit(:content)
  end
end
