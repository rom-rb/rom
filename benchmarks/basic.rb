#!/usr/bin/env ruby
# encoding: utf-8

Bundler.setup
Bundler.require

require 'benchmark'
require 'faker'
require 'rom'
require 'axiom-memory-adapter'
require 'rom/support/axiom/adapter/memory'

def env
 @env ||= ROM::Environment.setup(:memory => 'memory://test')
end

class User
  attr_reader :id, :name, :email, :age

  def initialize(attributes)
    @id, @name, @email, @age = attributes.values_at(:id, :name, :email, :age)
  end
end

env.schema do
  base_relation :users do
    repository :memory

    attribute :id,    Integer
    attribute :name,  String
    attribute :email, String
    attribute :age,   Integer

    key :id
  end
end

env.mapping do
  users do
    map :id, :name, :email, :age
    model User
  end
end

COUNT = ENV.fetch('COUNT', 10).to_i

SEED = COUNT.times.map do |i|
  { :id    => i + 1,
    :name  => Faker::Name.name,
    :email => Faker::Internet.email,
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

Benchmark.bm do |x|
  x.report("seed")            { seed }
  x.report("delete")          { delete }
  x.report("seed and delete") { seed and delete }
end
