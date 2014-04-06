#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler'

Bundler.require

profile = ENV['PROFILE'] || false

require 'perftools' if profile
require 'benchmark'
require 'rom'
require 'axiom-memory-adapter'

PerfTools::CpuProfiler.start("./tmp/rom_profile") if profile

class User
  attr_reader :id, :name, :email, :age

  def initialize(attributes)
    @id, @name, @email, @age = attributes.values_at(:id, :name, :email, :age)
  end
end

def env
  ROM_ENV
end

ROM_ENV = ROM::Environment.setup(:memory => 'memory://test') do
  schema do
    base_relation :users do
      repository :memory

      attribute :id,    Integer
      attribute :name,  String
      attribute :email, String
      attribute :age,   Integer

      key :id
    end
  end

  mapping do
    relation(:users) do
      map :id, :name, :email, :age
      model User
    end
  end
end

COUNT = ENV.fetch('COUNT', 100).to_i

SEED = COUNT.times.map do |i|
  { :id    => i + 1,
    :name  => "name #{i}",
    :email => "email_{i}@domain.com",
    :age   => i*10 }
end

def seed
  env.session do |session|
    SEED.each do |attributes|
      if env[:users].restrict(attributes).count == 0
        user = session[:users].new(attributes)
        session[:users].save(user)
      end
    end

    session.flush
  end
end

def delete
  env[:users].each { |user| env[:users].delete(user) }
end
if profile
  seed and delete
  PerfTools::CpuProfiler.stop
else
  Benchmark.bm do |x|
    x.report("seed")            { seed }
    x.report("delete")          { delete }
    x.report("seed and delete") { seed and delete }
  end
end
