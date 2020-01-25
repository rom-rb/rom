# frozen_string_literal: true

# this file is managed by rom-rb/devtools

if ENV['COVERAGE'] == 'true'
  require 'codacy-coverage'

  Codacy::Reporter.start
end
