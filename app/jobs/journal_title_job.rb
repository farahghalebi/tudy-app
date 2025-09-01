class JournalTitleJob < ApplicationJob
  queue_as :default

  def perform(journal, journal_app_prompt, title_prompt)
    # Do something later
    puts "🐰🐰🐰 Performing TITLE Job 🐰🐰🐰"
    journal.title = RubyLLM.chat.with_instructions(journal_app_prompt).ask("#{title_prompt} for this journal entry: #{journal.content}").content
    journal.save
    puts "🐰🐰🐰 #{journal.title} 🐰🐰🐰"
    puts "🐰🐰🐰 TITLE Job DONE 🐰🐰🐰"
  end
end
