class JournalFileJob < ApplicationJob
  queue_as :default

  def perform(journal, journal_app_prompt, file_prompt)
    # Do something later
    puts "🐰🐰🐰 Performing FILE Job 🐰🐰🐰"

    if journal.file.content_type == "application/pdf"
      puts "🐰🐰🐰 Performing PDF Job 🐰🐰🐰"

      file_response = RubyLLM.chat.with_instructions(journal_app_prompt)
                             .ask("#{file_prompt}", with:{pdf: journal.file.url })
                             .content

    elsif journal.file.image?
      puts "🐰🐰🐰 Performing IMAGE Job 🐰🐰🐰"

      file_response = RubyLLM.chat.with_instructions(journal_app_prompt)
                        .ask("#{file_prompt}", with:{image: journal.file.url })
                        .content

    # AUDIO WIP (@david) ------------------------------------------------
    # elsif journal.file.audio?
    #   puts "🐰🐰🐰 Performing AUDIO Job 🐰🐰🐰"

    #   # Download the file to a temporary location before sending it to the model.
    #   Dir.mktmpdir do |dir|
    #     require 'open-uri'
    #     temp_file_path = File.join(dir, journal.file.filename.to_s)

    #     URI.open(journal.file.url) do |remote_file|
    #       File.open(temp_file_path, 'wb') do |file|
    #         file.write(remote_file.read)
    #       end
    #     end

    #     file_response = RubyLLM.chat.with_instructions(journal_app_prompt)
    #                     .ask("#{file_prompt}", with: {audio: temp_file_path})
    #                     .content
    #   end

    end

    if journal.content
      journal.content += file_response
    else
      journal.content = file_response
    end
      journal.save

    puts "🐰🐰🐰 #{journal.content} 🐰🐰🐰"
    puts "🐰🐰🐰 FILE Job DONE 🐰🐰🐰"
  end
end
