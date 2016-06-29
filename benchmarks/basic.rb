require_relative 'setup'

benchmark('creating a user') do |x|
  x.report('rom-repository') do
    user_repo.create(name: 'Jane', email: 'jane@doe.org', age: 21)
  end

  x.report('sequel') do
    Sequel::User.create(name: 'Jane', email: 'jane@doe.org', age: 21)
  end

  x.report('activerecord') do
    AR::User.create(name: 'Jane', email: 'jane@doe.org', age: 21)
  end

  x.compare!
end
