# frozen_string_literal: true

require_relative "rom"
require "rom-changeset"

Dir[File.join(__dir__, "legacy/**/*.rb")].sort.each do |file|
  require_relative "#{file}"
end
