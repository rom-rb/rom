require 'pp'
require 'backports'
require 'backports/basic_object' unless defined?(BasicObject)

require 'virtus'
require 'rspec'

require 'dm-mapper'
require 'data_mapper/support/veritas/adapter/postgres'
require 'data_mapper/support/graphviz'

require 'shared_helper'

require 'db_setup'

include(DataMapper)

RSpec.configure do |config|

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.after(:all) do
    DM_ENV.reset
  end

  config.before do
    DM_ENV.finalize
  end

  config.include(SpecHelper)
end

DM_ENV = TestEnv.coerce(REPOSITORY => URI)
