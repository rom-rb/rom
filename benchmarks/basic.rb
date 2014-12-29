#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'setup'

run("Loading ONE user object") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.by_name('name 1').first }
    x.report("ROM") { users.by_name('name 1').first }
    x.compare!
  end
end

run("Loading 1k user objects") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.all.to_a }
    x.report("ROM") { users.all.to_a }
    x.compare!
  end
end

run("Loading 1k users with their tasks") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.all.includes(:tasks).to_a }
    x.report("ROM") { users.all.with_tasks.to_a }
    x.compare!
  end
end

run("Loading 3k tasks with their users") do
  Benchmark.ips do |x|
    x.report("AR") { ARTask.all.includes(:user).to_a }
    x.report("ROM") { tasks.with_user.to_a }
    x.compare!
  end
end

run("Loading 3k tasks with their users and tags") do
  Benchmark.ips do |x|
    x.report("AR") { ARTask.all.includes(:user).includes(:tags).to_a }
    x.report("ROM") { tasks.all.with_user.with_tags.to_a }
    x.compare!
  end
end

run("to_json on 1k user objects") do
  Benchmark.ips do |x|
    x.report("AR") { ARUser.all.to_a.to_json }
    x.report("ROM") { users.user_json.to_a.to_json }
    x.compare!
  end
end
