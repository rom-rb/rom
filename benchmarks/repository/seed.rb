# frozen_string_literal: true

USER_SEED = COUNT.times.map { |i|
  {id: i + 1,
   name: "User #{i + 1}",
   email: "email_#{i}@domain.com",
   age: i * 10}
}

TASK_SEED = USER_SEED.map { |user|
  3.times.map do |i|
    {user_id: user[:id], title: "Task #{i + 1}"}
  end
}.flatten

def seed
  hr

  puts "SEEDING #{USER_SEED.count} users"
  USER_SEED.each do |attributes|
    rom.relations.users.insert(attributes)
  end

  puts "SEEDING #{TASK_SEED.count} tasks"
  TASK_SEED.each do |attributes|
    rom.relations.tasks.insert(attributes)
  end

  hr
end

seed

hr
puts "INSERTED #{rom.relations.users.count} users via ROM/Sequel"
puts "INSERTED #{rom.relations.tasks.count} tasks via ROM/Sequel"
hr
