require_relative 'setup'
require 'hotch'

Hotch() do
  100.times do
    user_repo.aggregate(:tasks).to_a
  end
end
