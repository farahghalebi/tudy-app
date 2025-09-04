# Seeds for Users, Journals, Todos, Reminders, and Tags
Reminder.destroy_all
Todo.destroy_all
Tag.destroy_all
Journal.destroy_all
User.destroy_all

puts "🐰🐰🐰 Starting seeding... 🐰🐰🐰"

ActiveRecord::Base.transaction do

  # Use Timestamps ---------------------
  base_time = Time.current

  # User ----------------------------------------------------
  user = User.find_or_create_by!(email: "me@tudy.me") do |u|
    u.password = "666666"
    u.password_confirmation = "666666"
  end
  puts "🐰🐰🐰 User: #{user.email}, Password: #{user.password} 🐰🐰🐰"

  # Journals ------------------------------------------------
  journals_data = [
    {
      title: "Bouldering & Balance",
      offset: 6,
      content: <<~TXT.squish,
        The week started strong at Le Wagon. Our team dug deep into building out the prototype for the journaling app,
        and it feels like the puzzle pieces are finally starting to come together. After hours of coding and debugging,
        I forced myself to step away and go bouldering. My body thanked me for moving, and I felt lighter afterwards.
        I cooked a proper dinner—lots of veggies and a simple stir-fry—and reminded myself how much better I feel when I eat clean.
        Tomorrow I’ll need to refine some parts of the prototype and maybe sketch out the pitch slides so it doesn’t all pile up later.
        I should also keep the healthy streak going—maybe prep some food in advance.
      TXT
      summary: "Started the week strong at Le Wagon, balanced with bouldering and a healthy dinner."
    },
    {
      title: "Slow Progress",
      offset: 5,
      content: <<~TXT.squish,
        Another long day at Le Wagon. We wrestled with authentication logic, and though progress was slow, I’m glad we didn’t give up.
        I stayed later than I wanted, which meant no yoga, but I promised myself to go later this week.
        In the evening I just stretched at home and let music play while I decompressed.
        I want to make sure I actually block time for yoga on Thursday.
        And I should check in with Kat or Alex to see if we can plan something for after the bootcamp—it’s too easy to lose touch.
      TXT
      summary: "A draining day at bootcamp with no yoga, but small steps forward."
    },
    {
      title: "Sunshine & Friends",
      offset: 4,
      content: <<~TXT.squish,
        Today was a gift. The sun poured over Hasenheide and Tempelhofer Feld, and I spent hours with Kat, Sujin, Alex, Lucas, Olivier, and others.
        We sprawled in the grass, laughed about little things, and let the day melt. For a moment, all the stress of bootcamp vanished, replaced by friends,
        warmth, and the simple joy of being outside.
        I told myself I want more days like this after Demo Day is behind us. For now, I’ll have to juggle,
        but I’d like to send a message later this week to plan another hangout for when we’re all less busy.
      TXT
      summary: "A beautiful day outdoors with friends at Hasenheide and Tempelhofer Feld."
    },
    {
      title: "Grounded in Yoga",
      offset: 3,
      content: <<~TXT.squish,
        Back to the grind. Bootcamp drained me today—bug after bug, and yet we’re inching closer to something real. After class I pushed myself to yoga,
        and the moment I stepped onto the mat I felt my mind settle. My body felt stiff from sitting all week, but by the end, I was breathing deeper.
        I went home, made a simple lentil curry, and realized how grounding cooking can be.
        Tomorrow is all about the app again. I’ll need to polish the UI and think about how to show the core flow during the demo.
        Maybe tonight I’ll sketch a rough outline for the pitch so it doesn’t sneak up on me.
      TXT
      summary: "Exhausting day of coding, eased by yoga and cooking lentil curry."
    },
    {
      title: "Pre-Demo Nerves",
      offset: 2,
      content: <<~TXT.squish,
        Demo Day is tomorrow, and nerves are buzzing. We rehearsed our presentation, and I can feel the pressure mounting.
        Still, there’s a thrill in seeing our little journaling app take shape, even if it’s only a prototype.
        I feel proud of the team, even through the exhaustion.
        Tonight, I’ll keep it calm. Early to bed, maybe review the pitch one last time. Tomorrow I’ll need steady nerves, clear words,
        and enough energy to enjoy the celebration after all this hard work.
      TXT
      summary: "Final preparations and rehearsals for the big Demo Day presentation."
    },
    {
      title: "Berghain & Kitkat",
      offset: 1,
      content: <<~TXT.squish,
        What a night. After Demo Day’s whirlwind, I let loose at Berghain. The music consumed me—deep, endless waves that carried me past exhaustion into pure flow.
        I found myself with this beautiful polyamorous couple; the way they held each other, and me, felt both tender and electric.
        Later, at Kitkat, I made out with a gay couple, laughter and sweat blurring everything.
        The MDMA opened me, softened the edges, and when a fetish guy spanked me in play, I felt oddly safe in surrender.
        Tomorrow I’ll need space to come down. Water, rest, maybe journaling out what I felt tonight so I don’t forget the beauty in the chaos.
      TXT
      summary: "Let loose in Berlin’s nightlife, connecting deeply with couples and on MDMA."
    },
    {
      title: "Tender Comedown",
      offset: 0,
      content: <<~TXT.squish,
        The weekend blurred into another night of freedom at Kitkat. Bodies, music, desire—it was overwhelming and gorgeous.
        I felt both raw and alive, stretched beyond my usual limits.
        But the comedown is here now, and I can feel the tenderness in my body and mind. I stayed in bed late, letting silence slowly stitch me back together.
        Tomorrow starts another week, and I’ll need to gather myself for it. Work is waiting, but so is yoga, so is cooking.
        Maybe tonight I’ll take a walk, breathe some fresh air, and remind myself that the balance is in the return.
      TXT
      summary: "After another night at Kitkat, rested and reflected while preparing to reset."
    }
  ]

  journals = {}
  journals_data.each do |data|
    created_time = base_time - data[:offset].days
    journal = Journal.find_or_create_by!(title: data[:title], user_id: user.id) do |j|
      j.content = data[:content]
      j.summary = data[:summary]
      j.created_at = created_time
      j.updated_at = created_time
    end
    journals[data[:title]] = journal
  end
  puts "🐰🐰🐰 #{Journal.count} - Journals created for #{user.email}"

  # Todos ---------------------------------------------------
  todos_data = [
    { title: "Refine prototype", description: "Refine some parts of the prototype", due_date: Date.today + 1, status: false, journal: journals["Bouldering & Balance"] },
    { title: "Sketch pitch slides", description: "Sketch out the pitch slides", due_date: Date.today + 1, status: false, journal: journals["Bouldering & Balance"] },
    { title: "Prep meals", description: "Prep some food in advance", due_date: Date.today + 1, status: false, journal: journals["Bouldering & Balance"] },

    { title: "Block yoga time", description: "Block time for yoga on Thursday", due_date: Date.today + 2, status: false, journal: journals["Slow Progress"] },
    { title: "Check in with friends", description: "Check in with Kat or Alex", due_date: Date.today + 2, status: false, journal: journals["Slow Progress"] },

    { title: "Plan hangout", description: "Send a message later this week to plan another hangout", due_date: Date.today + 3, status: false, journal: journals["Sunshine & Friends"] },

    { title: "Polish UI", description: "Polish the UI for Demo Day", due_date: Date.today + 4, status: false, journal: journals["Grounded in Yoga"] },
    { title: "Show core flow", description: "Think about how to show the core flow during the demo", due_date: Date.today + 5, status: false, journal: journals["Grounded in Yoga"] },
    { title: "Sketch pitch outline", description: "Sketch a rough outline for the pitch", due_date: Date.today, status: false, journal: journals["Grounded in Yoga"] },

    { title: "Review pitch", description: "Review the pitch one last time", due_date: Date.today, status: false, journal: journals["Pre-Demo Nerves"] },

    { title: "Come down safely", description: "Water, rest, journaling", due_date: Date.today + 7, status: false, journal: journals["Berghain & Kitkat"] },

    { title: "Gather myself", description: "Gather myself for the week", due_date: Date.today + 8, status: false, journal: journals["Tender Comedown"] },
    { title: "Yoga session", description: "Do yoga", due_date: Date.today + 6, status: false, journal: journals["Tender Comedown"] },
    { title: "Cook healthy meals", description: "Cooking", due_date: Date.today + 7, status: false, journal: journals["Tender Comedown"] },
    { title: "Take a walk", description: "Take a walk, breathe fresh air", due_date: Date.today + 1, status: false, journal: journals["Tender Comedown"] }
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
  puts "🐰🐰🐰 #{Todo.count} - Todos created 🐰🐰🐰"

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
    { todo: "Refine prototype", day: 1 },
    { todo: "Sketch pitch slides", day: 1 },
    { todo: "Prep meals", day: 1 },
    { todo: "Block yoga time", day: 2 },
    { todo: "Check in with friends", day: 2 },
    { todo: "Plan hangout", day: 3 },
    { todo: "Polish UI", day: 4 },
    { todo: "Show core flow", day: 4 },
    { todo: "Sketch pitch outline", day: 4 },
    { todo: "Review pitch", day: 5 },
    { todo: "Come down safely", day: 6 },
    { todo: "Gather myself", day: 7 },
    { todo: "Yoga session", day: 7 },
    { todo: "Cook healthy meals", day: 7 },
    { todo: "Take a walk", day: 7 }
  ]

  reminders_data.each do |data|
    todo = todos[data[:todo]]
    Reminder.find_or_create_by!(todo_id: todo.id, delay: data[:day])
  end
  puts "🐰🐰🐰 #{Reminder.count} - Reminders created 🐰🐰🐰"

  # Tags -------------------------------------------------------------------
  tags_data = [
    { name: "Work", content: "Prototype & pitch tasks", journal: "Bouldering & Balance", todo: "Refine prototype" },
    { name: "Work", content: "Prototype & pitch tasks", journal: "Bouldering & Balance", todo: "Sketch pitch slides" },
    { name: "Health", content: "Meal prep & wellness", journal: "Bouldering & Balance", todo: "Prep meals" },

    { name: "Health", content: "Yoga & self-care", journal: "Slow Progress", todo: "Block yoga time" },
    { name: "Social", content: "Friends catchup", journal: "Slow Progress", todo: "Check in with friends" },

    { name: "Social", content: "Plan hangouts after bootcamp", journal: "Sunshine & Friends", todo: "Plan hangout" },

    { name: "Work", content: "Demo Day prep", journal: "Grounded in Yoga", todo: "Polish UI" },
    { name: "Work", content: "Demo Day prep", journal: "Grounded in Yoga", todo: "Show core flow" },
    { name: "Work", content: "Demo Day prep", journal: "Grounded in Yoga", todo: "Sketch pitch outline" },

    { name: "Work", content: "Final pitch review", journal: "Pre-Demo Nerves", todo: "Review pitch" },

    { name: "Health", content: "Post-party recovery", journal: "Berghain & Kitkat", todo: "Come down safely" },

    { name: "Health", content: "Reset & self-care", journal: "Tender Comedown", todo: "Gather myself" },
    { name: "Health", content: "Reset & self-care", journal: "Tender Comedown", todo: "Yoga session" },
    { name: "Health", content: "Reset & self-care", journal: "Tender Comedown", todo: "Cook healthy meals" },
    { name: "Health", content: "Reset & self-care", journal: "Tender Comedown", todo: "Take a walk" }
  ]

  tags_data.each do |data|
    journal = journals[data[:journal]]
    todo    = todos[data[:todo]]
    Tag.find_or_create_by!(name: data[:name], journal_id: journal.id, todo_id: todo.id) do |tag|
      tag.content = data[:content]
    end
  end
  puts "🐰🐰🐰 #{Tag.count} - Tags created 🐰🐰🐰"
end

puts "🐰🐰🐰 Seeding complete! 🐰🐰🐰"
