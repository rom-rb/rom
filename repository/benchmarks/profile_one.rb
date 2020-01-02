require_relative './setup'
require_relative './seed'
require 'hotch'

Hotch() do
  COUNT.times do |i|
    user_repo[i + 1]
  end
end
