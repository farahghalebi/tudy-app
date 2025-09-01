require "json"

class JournalTagsJob < ApplicationJob
  queue_as :default

  def perform(journal, journal_app_prompt, tags_prompt)
    # Do something later
    puts "🐰🐰🐰 Performing TAGS Job 🐰🐰🐰"
    tags_response = RubyLLM.chat.with_instructions(journal_app_prompt).ask("#{tags_prompt} #{journal.content}").content
    tags_json = JSON.parse(tags_response)

    tags_json.each do |tag_json|
      tag = Tag.new
      tag.name = tag_json["name"]
      tag.content = tag_json["content"]
      tag.journal_id = journal.id
      tag.save
      puts "🐰🐰🐰 TAG: #{tag.name} 🐰🐰🐰"
    end

    puts "🐰🐰🐰 TAGS Job DONE 🐰🐰🐰"
  end
end
