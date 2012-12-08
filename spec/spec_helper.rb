require 'pp'
require 'ostruct'
require 'dm-mapper'
require 'virtus'

require 'data_mapper/engine/veritas'

require 'rspec'

%w(shared support).each do |name|
  Dir[File.expand_path("../#{name}/**/*.rb", __FILE__)].each { |file| require file }
end

RSpec.configure do |config|

  config.before(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      @test_env = TestEnv.instance
    end
  end

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      @test_env.clear!
    end
  end

  config.include(SpecHelper)
end

include DataMapper

TEST_ENGINE = TestEngine.new('db://localhost/test')
DataMapper.engines[:test] = TEST_ENGINE
