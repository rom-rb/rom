#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'setup'

run("Loading ONE user object") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARUser.by_name('User 1').first
    end
    x.report("ROM") do
      users.by_name('User 1').as(:users).one
    end
    x.compare!
  end
end

run("Loading ALL user objects") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARUser.all.to_a
    end
    x.report("ROM") do
      users.all.as(:users).to_a
    end
    x.compare!
  end
end

run("Loading ALL users with their tasks") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARUser.all.includes(:tasks).to_a
    end
    x.report("ROM") do
      users.all.with_tasks.as(:user_with_tasks).to_a
    end
    x.compare!
  end
end

run("Loading ONE task with its user and tags") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARTask.all
        .includes(:user)
        .includes(:tags)
        .where(users: { name: 'User 1' }, tasks: { title: 'Task 1' })
        .to_a
    end
    x.report("ROM") do
      tasks_with_user_and_tags
        .where(users__name: 'User 1', tasks__title: 'Task 1')
        .to_a
    end
    x.compare!
  end
end

run("Loading ALL tasks with their users") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARTask.all.includes(:user).to_a
    end
    x.report("ROM") do
      tasks.with_user.as(:task_with_user).to_a
    end
    x.compare!
  end
end

run("Loading ALL tasks with their users and tags") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARTask.all.includes(:user).includes(:tags).to_a
    end
    x.report("ROM") do
      tasks.all.with_user.with_tags.as(:task_with_user_and_tags).to_a
    end
    x.compare!
  end
end

run("to_json on ALL user objects") do
  Benchmark.ips do |x|
    x.report("AR") do
      ARUser.all.to_a.to_json
    end
    x.report("ROM") do
      users.all.to_a.to_json
    end
    x.compare!
  end
end
