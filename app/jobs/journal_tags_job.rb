require "json"

class JournalTagsJob < ApplicationJob
  queue_as :default
# The predefined categories are now part of the job itself

  PREDEFINED_CATEGORIES = ['Work', 'Personal', 'Health', 'Study', 'Finance', 'Leisure', 'Social', 'Hobbies', 'Development']
# predefined sub categories in hash

  def perform(journal, journal_app_prompt)
    puts "🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰Performing TAGS Job "

    journal.todos.each do |todo|
      #  prompt for assigning categories
      tag_prompt = "You are a personal journaling assistant. Your task is to categorize the following to-do item into the most fitting overarching category.
      Overarching Categories: #{PREDEFINED_CATEGORIES.join(', ')}.

      To-Do Item: \"#{todo.title}: #{todo.description}\"

      INSTRUCTIONS:
      1. Choose ONE single overarching category from the provided list that best fits the to-do item.
      2. Choose a specific subcategory for the to-do item. The subcategory should be a single, descriptive word (e.g., 'Errands', 'Meetings', 'Emails').
      3. Return ONLY a valid JSON object in this exact format:
      {
        \"category\": \"The chosen overarching category\"
      }

      Example:
      To-Do: \"Buy groceries: I need to rush to the supermarket\".
      Response:
      {
        \"category\": \"Personal\"}
      "

      tag_response = RubyLLM.chat.with_instructions(journal_app_prompt).ask(tag_prompt).content
      p "🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰"
      begin
        tags_json = JSON.parse(tag_response)

        # Create the tag and assign it to the todo
        tag = Tag.new
        tag.name = tags_json["category"]
        # tag.content = tags_json["subcategory"] # we dont do the sub categories for now we'll do it later
        tag.todo_id = todo.id
        if tag.save
          puts "🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰🐰TAG: #{tag.name} "
        else
          puts "❌❌❌ Failed to save tag: #{tag.errors.full_messages.join(", ")} ❌❌❌"
        end
      end
    end
  end
end
