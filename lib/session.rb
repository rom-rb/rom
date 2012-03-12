if RUBY_VERSION < '1.9'
  require 'backports'
end

require 'set'

module Session; end

require 'session/session'
