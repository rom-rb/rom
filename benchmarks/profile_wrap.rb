# frozen_string_literal: true

require_relative 'setup'
require 'hotch'

rel = tasks.limit(100).wrap(:user)

rel.to_a

Hotch() do
  1000.times do
    rel.each { |t| t.user.name }
  end
end
