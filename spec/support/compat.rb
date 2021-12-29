# frozen_string_literal: true

require_relative "rom"

require "rom/compat"

Dir[File.join(__dir__, "compat/**/*.rb")].sort.each do |file|
  require_relative file.to_s
end
