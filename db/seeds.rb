# Seeds for Users, Journals, Todos, Reminders, and Tags
Reminder.destroy_all
Tag.destroy_all
Todo.destroy_all
Journal.destroy_all
User.destroy_all

puts "Starting seeding..."

ActiveRecord::Base.transaction do
  # --- User ----------------------------------------------------
  user = User.find_or_create_by!(email: "fake_user@example.com") do |u|
    u.password = "password"
    u.password_confirmation = "password"
  end
  puts "User: #{user.email}"

  # Journals ------------------------------------------------
  journals_data = [
    {
      title: "Project Week Kickoff",
      content: "Le Wagon project week started with demo day. Showcase coming soon. We need to demo on Sep 6th.",
      summary: "Busy sprint, showcase prep, plus life admin tasks."
    },
    {
      title: "Come back to Paris and paperwork in Iran",
      content: <<~TXT.squish,
        I'm going back to Paris on September 8th, then traveling to Iran to handle some paperwork and finally
        get everything done. It’s something very important that I need to finish, even if it takes extra time and money.
        I have until the end of September to complete it—about two weeks—so I can see my family after such a long time.
        But I need to be back in Paris before October 1st.
      TXT
      summary: "Travel + paperwork timeline."
    },
    {
      title: "Life Admin Roundup",
      content: <<~TXT.squish,
        Last night I finally had some time to step away from work and talk with my family.
        I also did my groceries and a bit of cleaning, but I still need to do a deep clean of the apartment before Monday.
        On top of that, I need to sort out my apartment contract in Paris and finalize the company’s bank account.
      TXT
      summary: "Family time + home chores + admin."
    }
  ]

  journals = {}
  journals_data.each do |data|
    journal = Journal.find_or_create_by!(title: data[:title], user_id: user.id) do |j|
      j.content = data[:content]
      j.summary = data[:summary]
    end
    journals[data[:title]] = journal
  end
  puts "Journals: #{Journal.count}"

  # Todos ---------------------------------------------------
  todos_data = [
    { title: "Deep clean the apartment", description: "Do kitchen, bathroom, floors", due_date: Date.today.end_of_week,
      status: false, journal: journals["Life Admin Roundup"] },
    { title: "Groceries restock", description: "Vegetables, snacks, basics", due_date: Date.today, status: true,journal:journals["Life Admin Roundup"] },
    { title: "Prepare showcase deck", description: "Slides + dry run rehearsal", due_date: Date.today + 1, status: false, journal: journals["Project Week Kickoff"] },
    { title: "Finish company bank account setup", description: "Submit docs & confirm", due_date: Date.today + 7, status: false, journal: journals["Life Admin Roundup"] },
    { title: "Get apartment contract in Paris", description: "Collect contract & check clauses", due_date: Date.today + 10, status: false, journal: journals["Life Admin Roundup"] },
    { title: "Flight to Paris (Sep 8)", description: "Check-in, luggage, transport", due_date: Date.new(2025, 9, 8), status: false, journal: journals["Come back to Paris and paperwork in Iran"] },
    { title: "Plan Iran trip & paperwork", description: "Appointments, documents checklist", due_date: Date.today + 30, status: false, journal: journals["Come back to Paris and paperwork in Iran"] }
  ]

  todos = {}
  todos_data.each do |data|
    todo = Todo.find_or_create_by!(title: data[:title], user_id: user.id, journal_id: data[:journal].id) do |t|
      t.description = data[:description]
      t.due_date    = data[:due_date]
      t.status      = data[:status]
    end
    todos[data[:title]] = todo
  end
  puts "Todos: #{Todo.count}"

  # Reminders -------------------------------------------------------------
  reminders_data = [
    { todo: "Prepare showcase deck", day: 1 },
    { todo: "Flight to Paris (Sep 8)", day: 2 }
  ]
  reminders_data.each do |data|
    todo = todos[data[:todo]]
    Reminder.find_or_create_by!(todo_id: todo.id, delay: data[:day])
  end
  puts "Reminders: #{Reminder.count}"

  # Tags -------------------------------------------------------------------
  tags_data = [
    { name: "life-admin", content: "Home & paperwork", journal: "Life Admin Roundup", todo: "Deep clean the apartment" },
    { name: "work", content: "Showcase tasks", journal: "Project Week Kickoff", todo: "Prepare showcase deck" },
    { name: "travel", content: "Trips & documents", journal: "Come back to Paris and paperwork in Iran", todo: "Plan Iran trip & paperwork" }
  ]

  tags_data.each do |data|
    journal = journals[data[:journal]]
    todo    = todos[data[:todo]]
    Tag.find_or_create_by!(name: data[:name], journal_id: journal.id, todo_id: todo.id) do |tag|
      tag.content = data[:content]
    end
  end
  puts "Tags: #{Tag.count}"
end

puts "Seeding complete!"
