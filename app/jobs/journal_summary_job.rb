class JournalSummaryJob < ApplicationJob
  queue_as :default

  def perform(journal, journal_app_prompt, summary_prompt )
    # Do something later
    puts "🐰🐰🐰 Performing SUMMARY Job 🐰🐰🐰"
    journal.summary = RubyLLM.chat.with_instructions(journal_app_prompt).ask("#{summary_prompt} #{journal.content}").content
    journal.save
    puts "🐰🐰🐰 #{journal.summary} 🐰🐰🐰"
    puts "🐰🐰🐰 SUMMARY Job DONE 🐰🐰🐰"
  end
end
