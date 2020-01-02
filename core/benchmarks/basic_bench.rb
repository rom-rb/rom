#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'setup'

run('Loading ONE user object') do |x|
  x.verify do |user|
    user.name == 'User 1'
  end
  x.report('AR') do
    ARUser.by_name('User 1').first
  end
  x.report('ROM') do
    users.by_name('User 1').limit(1).first
  end
end

run('Loading ALL user objects') do |x|
  x.verify do |users|
    users.size == COUNT
  end
  x.report('AR') do
    ARUser.all.to_a.each do |u|
      u.name
    end
  end
  x.report('ROM') do
    users.to_a.each do |u|
      u.name
    end
  end

  x.report('ROM (auto_struct: false)') do
    users_hashes.to_a.each do |u|
      u[:name]
    end
  end
end

run('Loading ALL users with their tasks') do |x|
  x.verify do |users|
    users.size == COUNT
  end

  x.report('AR') do
    ARUser.includes(:tasks).all.to_a.each do |u|
      u.tasks.to_a.size
    end
  end

  x.report('ROM') do
    users.combine(:tasks).to_a.each do |u|
      u.tasks.to_a.size
    end
  end
end

run('Loading 3000 posts with their users') do |x|
  x.verify do |users|
    users.size == COUNT
  end

  x.report('AR') do
    ARPost.includes(:users).all.to_a.each do |u|
      u.users.to_a.size
    end
  end

  x.report('ROM') do
    posts.combine(:users).to_a.each do |u|
      u.users.to_a.size
    end
  end
end

run('Loading 20 posts with their users') do |x|
  x.verify do |users|
    users.size == COUNT
  end

  x.report('AR') do
    ARPost.includes(:users).limit(20).all.to_a.each do |u|
      u.users.to_a.size
    end
  end

  x.report('ROM') do
    posts.combine(:users).limit(20).to_a.each do |u|
      u.users.to_a.size
    end
  end
end

run('Loading ALL users with their tasks with 20 limit') do |x|
  x.verify do |users|
    users.size == COUNT
  end
  x.report('AR') do
    ARUser.includes(:tasks).limit(20).all.to_a.each do |u|
      u.tasks.to_a.size
    end
  end
  x.report('ROM') do
    users.combine(:tasks).limit(20).to_a.each do |u|
      u.tasks.to_a.size
    end
  end
end

run('Loading ALL users with their tasks and their tags') do |x|
  x.verify do |users|
    users.size == COUNT
  end
  x.report('AR') do
    ARUser.includes(tasks: :tags).all.to_a.each do |u|
      u.tasks.each do |t|
        t.tags.to_a.size
      end
    end
  end
  x.report('ROM') do
    users.combine(tasks: :tags).to_a.each do |u|
      u.tasks.each do |t|
        t.tags.to_a.size
      end
    end
  end
end

run('Loading ONE task with its user and tags') do |x|
  x.verify do |task|
    task.title == 'Task 1'
  end
  x.report('AR') do
    t = ARTask.all.includes(:user, :tags).where(title: 'Task 1').first
    t.user.name
    t.tags.to_a.size
  end
  x.report('ROM') do
    t = tasks.combine(:user, :tags).where(title: 'Task 1').limit(1).first
    t.user.name
    t.tags.to_a.size
  end
end

run('Loading ALL tasks with their users') do |x|
  x.verify do |tasks|
    tasks.size == COUNT * 3
  end
  x.report('AR') do
    ARTask.all.includes(:user).to_a.each do |t|
      t.user.name
    end
  end
  x.report('ROM[wrap]') do
    tasks.wrap(:user).to_a.each do |t|
      t.user.name
    end
  end
  x.report('ROM[combine]') do
    tasks.combine(:user).to_a.each do |t|
      t.user.name
    end
  end
end

run('Loading ALL tasks with their users and tags') do |x|
  x.verify do |tasks|
    tasks.size == COUNT * 3
  end
  x.report('AR') do
    ARTask.all.includes(:user, :tags).to_a.each do |t|
      t.user.name
      t.tags.to_a.size
    end
  end
  x.report('ROM') do
    tasks.combine(:user, :tags).to_a.each do |t|
      t.user.name
      t.tags.to_a.size
    end
  end
end

run('to_json on ALL user objects') do |x|
  x.verify do |json|
    users = JSON(json)
    users.size == COUNT
  end
  x.report('AR') do
    ARUser.all.to_a.to_json
  end
  x.report('ROM') do
    users.with(auto_struct: false).to_a.to_json
  end
end
