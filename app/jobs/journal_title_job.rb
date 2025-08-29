class JournalTitleJob < ApplicationJob
  queue_as :default

  def perform(journal, journal_app_prompt, title_prompt)
    # Do something later
    puts "🐰🐰🐰 Performing Title Job 🐰🐰🐰"
    journal.title = RubyLLM.chat.with_instructions(journal_app_prompt).ask("#{title_prompt} for this journal entry: #{journal.content}").content
    puts "🐰🐰🐰 Title Job DONE 🐰🐰🐰"
    puts journal.title
  end
end
