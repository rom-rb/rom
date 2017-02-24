require_relative 'setup'
require 'hotch'

user_repo.users.by_name('User 1').one

Hotch() do
  1000.times do
    user_repo.users.by_name('User 1').one
  end
end
