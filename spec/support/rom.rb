# frozen_string_literal: true

Dir[File.join(__dir__, "*.rb")].sort.grep_v(/#{__FILE__}/).each do |file|
  require_relative "#{file}"
end
