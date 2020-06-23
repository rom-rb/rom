# frozen_string_literal: true

require_relative "setup"
require "hotch"

Hotch() do
  100.times do
    users.combine(:tasks).to_a
  end
end
