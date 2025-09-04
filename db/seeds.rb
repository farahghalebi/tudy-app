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
    }, # Extra journals for expanded tags_data
    {
      title: "Weekend Catchup",
      content: <<~TXT.squish,
        Family, calls, and errands on the weekend. A space to reflect and keep track of personal catch-ups.
      TXT
      summary: "Personal errands."
    },
    {
      title: "Bureaucracy Marathon",
      content: <<~TXT.squish,
        Paperwork and admin tasks for various offices. Notes on forms, deadlines, and bureaucratic processes.
      TXT
      summary: "Documents and forms."
    },
    {
      title: "Morning Check-in",
      content: <<~TXT.squish,
        Daily notes about health and wellbeing. A way to monitor routines, habits, and overall progress.
      TXT
      summary: "Routine + health tracking."
    },
    {
      title: "Dentist Reminder",
      content: <<~TXT.squish,
        Notes about dentist appointments and oral health. Record visits, reminders, and next steps.
      TXT
      summary: "Health appointments."
    },
    {
      title: "Mindfulness Log",
      content: <<~TXT.squish,
        Meditation and mental health tracking. Daily reflections and exercises to stay balanced.
      TXT
      summary: "Wellbeing."
    },
    {
      title: "Philosophy Notes",
      content: <<~TXT.squish,
        Reading Kant and taking notes. A journal to capture ideas, quotes, and reflections on philosophy.
      TXT
      summary: "Study philosophy."
    },
    {
      title: "Ruby OOP Exercises",
      content: <<~TXT.squish,
        Coding practice notes. Documenting Ruby object-oriented programming challenges and progress.
      TXT
      summary: "Ruby study tasks."
    },
    {
      title: "Revision Plan",
      content: <<~TXT.squish,
        Exam prep schedule. Organize study material, plan review sessions, and track progress.
      TXT
      summary: "Study revision."
    },
    {
      title: "Monthly Expenses",
      content: <<~TXT.squish,
        Budget breakdown with detailed records of monthly expenses. Keep financial habits transparent.
      TXT
      summary: "Finance log."
    },
    {
      title: "Investment Log",
      content: <<~TXT.squish,
        Notes on ETF portfolio and investments. Record strategies, performance, and decisions.
      TXT
      summary: "Savings & investments."
    },
    {
      title: "Payment Tracker",
      content: <<~TXT.squish,
        Bills and due dates. Track which payments are pending and which are complete.
      TXT
      summary: "Bills."
    },
    {
      title: "Summer Reading",
      content: <<~TXT.squish,
        Books for leisure. Document impressions, progress, and thoughts on each read.
      TXT
      summary: "Books list."
    },
    {
      title: "Film Notes",
      content: <<~TXT.squish,
        Movies watched and reviews. Capture reflections and highlights from film nights.
      TXT
      summary: "Movies log."
    },
    {
      title: "Catchups",
      content: <<~TXT.squish,
        Friends and social activities. Notes on gatherings, dinners, and conversations.
      TXT
      summary: "Friends log."
    },
    {
      title: "Concert Memories",
      content: <<~TXT.squish,
        Notes about concerts and gigs. Record setlists, memories, and experiences.
      TXT
      summary: "Events."
    },
    {
      title: "Volunteer Day",
      content: <<~TXT.squish,
        Community volunteering. Notes on activities, reflections, and outcomes.
      TXT
      summary: "Community."
    },
    {
      title: "Sketchbook Session",
      content: <<~TXT.squish,
        Drawing practice notes. Document sketches, progress, and creative experiments.
      TXT
      summary: "Art hobby."
    },
    {
      title: "Guitar Practice",
      content: <<~TXT.squish,
        Music learning log. Notes on chord progressions, practice routines, and goals.
      TXT
      summary: "Music hobby."
    },
    {
      title: "Recipe Experiments",
      content: <<~TXT.squish,
        Cooking experiments and discoveries. Record recipes, tweaks, and outcomes.
      TXT
      summary: "Cooking hobby."
    },
    {
      title: "Rails Progress Log",
      content: <<~TXT.squish,
        Bug fixes and Rails learning. Track issues, lessons learned, and improvements.
      TXT
      summary: "Dev log."
    },
    {
      title: "JavaScript Notes",
      content: <<~TXT.squish,
        Notes on JS learning. Document exercises, snippets, and key concepts.
      TXT
      summary: "Frontend learning."
    },
    {
      title: "Portfolio Update",
      content: <<~TXT.squish,
        Work on personal projects. Track updates, refactors, and improvements to showcase.
      TXT
      summary: "Projects log."
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
    { title: "Plan Iran trip & paperwork", description: "Appointments, documents checklist", due_date: Date.today + 30, status: false, journal: journals["Come back to Paris and paperwork in Iran"] },

    # Extra todos for expanded tags_data
    { title: "Call parents", description: "Weekly family catchup", due_date: Date.today + 2, status: false, journal: journals["Weekend Catchup"] },
    { title: "Renew passport", description: "Prepare docs for renewal", due_date: Date.today + 14, status: false, journal: journals["Bureaucracy Marathon"] },
    { title: "Go for a 5k run", description: "Morning run", due_date: Date.today, status: false, journal: journals["Morning Check-in"] },
    { title: "Book annual checkup", description: "Schedule dentist", due_date: Date.today + 5, status: false, journal: journals["Dentist Reminder"] },
    { title: "10 min meditation", description: "Daily meditation", due_date: Date.today, status: false, journal: journals["Mindfulness Log"] },
    { title: "Summarize Kant chapter", description: "Write study notes", due_date: Date.today + 3, status: false, journal: journals["Philosophy Notes"] },
    { title: "Finish inheritance challenge", description: "Ruby OOP practice", due_date: Date.today + 4, status: false, journal: journals["Ruby OOP Exercises"] },
    { title: "Create flashcards", description: "Prep for exam", due_date: Date.today + 7, status: false, journal: journals["Revision Plan"] },
    { title: "Update spreadsheet", description: "Log expenses", due_date: Date.today + 1, status: false, journal: journals["Monthly Expenses"] },
    { title: "Review ETF portfolio", description: "Check investments", due_date: Date.today + 10, status: false, journal: journals["Investment Log"] },
    { title: "Pay electricity bill", description: "Monthly payment", due_date: Date.today + 2, status: false, journal: journals["Payment Tracker"] },
    { title: "Start 'The Stranger'", description: "Begin reading Camus", due_date: Date.today + 1, status: false, journal: journals["Summer Reading"] },
    { title: "Watch 'Blade Runner 2049'", description: "Leisure movie night", due_date: Date.today + 5, status: false, journal: journals["Film Notes"] },
    { title: "Organize dinner with Marie", description: "Dinner reservation", due_date: Date.today + 6, status: false, journal: journals["Catchups"] },
    { title: "Buy tickets for gig", description: "Concert booking", due_date: Date.today + 12, status: false, journal: journals["Concert Memories"] },
    { title: "Sign up for local event", description: "Community volunteering", due_date: Date.today + 15, status: false, journal: journals["Volunteer Day"] },
    { title: "Draw 3 portraits", description: "Sketch practice", due_date: Date.today + 2, status: false, journal: journals["Sketchbook Session"] },
    { title: "Learn new chord progression", description: "Guitar practice", due_date: Date.today + 2, status: false, journal: journals["Guitar Practice"] },
    { title: "Try homemade ramen", description: "Cooking hobby", due_date: Date.today + 4, status: false, journal: journals["Recipe Experiments"] },
    { title: "Fix controller bug", description: "Debug Rails controller", due_date: Date.today + 1, status: false, journal: journals["Rails Progress Log"] },
    { title: "Practice array methods", description: "JS exercises", due_date: Date.today + 3, status: false, journal: journals["JavaScript Notes"] },
    { title: "Polish project readme", description: "Improve docs", due_date: Date.today + 5, status: false, journal: journals["Portfolio Update"] }
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

    # Create a standalone todo list
  # Todo.find_or_create_by!(title: "Write a blog post", user: user) do |t|
  #   t.description = "Finish the blog post on Rails best practices."
  #   t.status = false
  # end

  # Create another standalone todo
  # Todo.find_or_create_by!(title: "Plan vacation", user: user) do |t|
  #   t.description = "Research destinations and book flights."
  #   t.status = false
  # end

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
  { name: "Personal", content: "Home & paperwork", journal: "Life Admin Roundup", todo: "Deep clean the apartment" },
  { name: "Work", content: "Showcase tasks", journal: "Project Week Kickoff", todo: "Prepare showcase deck" },
  { name: "Leisure", content: "Trips & documents", journal: "Come back to Paris and paperwork in Iran", todo: "Plan Iran trip & paperwork" },
  { name: "Personal", content: "Family & errands", journal: "Weekend Catchup", todo: "Call parents" },
  { name: "Personal", content: "Documents", journal: "Bureaucracy Marathon", todo: "Renew passport" },
  { name: "Health", content: "Routine", journal: "Morning Check-in", todo: "Go for a 5k run" },
  { name: "Health", content: "Appointments", journal: "Dentist Reminder", todo: "Book annual checkup" },
  { name: "Health", content: "Wellbeing", journal: "Mindfulness Log", todo: "10 min meditation" },
  { name: "Study", content: "Readings", journal: "Philosophy Notes", todo: "Summarize Kant chapter" },
  { name: "Study", content: "Practice", journal: "Ruby OOP Exercises", todo: "Finish inheritance challenge" },
  { name: "Study", content: "Exams", journal: "Revision Plan", todo: "Create flashcards" },
  { name: "Finance", content: "Budgeting", journal: "Monthly Expenses", todo: "Update spreadsheet" },
  { name: "Finance", content: "Savings", journal: "Investment Log", todo: "Review ETF portfolio" },
  { name: "Finance", content: "Bills", journal: "Payment Tracker", todo: "Pay electricity bill" },
  { name: "Leisure", content: "Books", journal: "Summer Reading", todo: "Start 'The Stranger'" },
  { name: "Leisure", content: "Movies", journal: "Film Notes", todo: "Watch 'Blade Runner 2049'" },
  { name: "Social", content: "Friends", journal: "Catchups", todo: "Organize dinner with Marie" },
  { name: "Social", content: "Events", journal: "Concert Memories", todo: "Buy tickets for gig" },
  { name: "Social", content: "Community", journal: "Volunteer Day", todo: "Sign up for local event" },
  { name: "Hobbies", content: "Art", journal: "Sketchbook Session", todo: "Draw 3 portraits" },
  { name: "Hobbies", content: "Music", journal: "Guitar Practice", todo: "Learn new chord progression" },
  { name: "Hobbies", content: "Cooking", journal: "Recipe Experiments", todo: "Try homemade ramen" },
  { name: "Development", content: "Coding", journal: "Rails Progress Log", todo: "Fix controller bug" },
  { name: "Development", content: "Learning", journal: "JavaScript Notes", todo: "Practice array methods" },
  { name: "Development", content: "Projects", journal: "Portfolio Update", todo: "Polish project readme" }
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
