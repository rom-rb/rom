# frozen_string_literal: true

Dir[File.join(__dir__, "*.rb")].sort.grep_v(/#{__FILE__}|compat/).each do |file|
  require_relative file.to_s
end
