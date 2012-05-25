if RUBY_VERSION < '1.9'
  require 'backports'
end

require 'set'

require 'session/operation'
require 'session/session'
require 'session/autocommit'
