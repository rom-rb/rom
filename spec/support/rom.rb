# frozen_string_literal: true

# TODO: each spec file should require its dependencies. Maybe we'll get there one day
require "rom/core"
require "rom/compat" # TODO: move this to support/compat eventually.
require "rom/memory"


Dir[File.join(__dir__, "*.rb")].sort.grep_v(/#{__FILE__}/).each do |file|
  require_relative "#{file}"
end
