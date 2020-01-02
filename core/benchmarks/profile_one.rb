# frozen_string_literal: true

require_relative 'setup'
require 'hotch'

users.by_name('User 1').one

Hotch() do
  1000.times do
    users.by_name('User 1').one
  end
end
