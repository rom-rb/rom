#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'setup'

run("Loading ONE user object") do |x|
  x.verify do |user|
    user.name == 'User 1'
  end
  x.report("AR") do
    ARUser.by_name('User 1').first
  end
  x.report("ROM") do
    users.by_name('User 1').first
  end
end

run("Loading ALL user objects") do |x|
  x.verify do |users|
    users.size == COUNT
  end
  x.report("AR") do
    ARUser.all.to_a
  end
  x.report("ROM") do
    users.all.to_a
  end
end

run("Loading ALL users with their tasks") do |x|
  x.verify do |users|
    users.size == COUNT
  end
  x.report("AR") do
    ARUser.includes(:tasks).all.to_a
  end
  x.report("ROM") do
    users_with_tasks.all.to_a
  end
end

run("Loading ONE task with its user and tags") do |x|
  x.verify do |task|
    task.title == 'Task 1'
  end
  x.report("AR") do
    ARTask.all
      .includes(:user)
      .includes(:tags)
      .where(users: { name: 'User 1' }, tasks: { title: 'Task 1' })
      .first
  end
  x.report("ROM") do
    tasks_with_user_and_tags { |relation|
      relation.where(users__name: 'User 1', tasks__title: 'Task 1')
    }.first
  end
end

run("Loading ALL tasks with their users") do |x|
  x.verify do |tasks|
    tasks.size == COUNT * 3
  end
  x.report("AR") do
    ARTask.all.includes(:user).to_a
  end
  x.report("ROM") do
    tasks.with_user.as(:task_with_user).to_a
  end
end

run("Loading ALL tasks with their users and tags") do |x|
  x.verify do |tasks|
    tasks.size == COUNT * 3
  end
  x.report("AR") do
    ARTask.all.includes(:user).includes(:tags).to_a
  end
  x.report("ROM") do
    tasks.all.with_user.with_tags.as(:task_with_user_and_tags).to_a
  end
end

run("to_json on ALL user objects") do |x|
  x.verify do |json|
    users = JSON(json)
    users.size == COUNT
  end
  x.report("AR") do
    ARUser.all.to_a.to_json
  end
  x.report("ROM") do
    users.all.to_a.to_json
  end
end
