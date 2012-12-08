require 'spec_helper'

require 'veritas-do-adapter'
require 'do_postgres'

require 'data_mapper/engine/arel'

require 'db_setup'

RSpec.configure do |config|
  config.before(:all) do
    @test_env = TestEnv.instance
  end

  config.after(:all) do
    @test_env.clear_mappers!
  end

  config.before do
    #DataMapper.finalize
  end
end
