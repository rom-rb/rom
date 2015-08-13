require 'spec_helper'

RSpec.describe ROM::Environment do
  it 'is configurable' do
    env = ROM::Environment.new

    env.configure do |config|
      config.sql.infer_schema = false
    end

    expect(env.config.sql.infer_schema).to be(false)

    expect(env.config).to respond_to(:sql)
    expect(env.config).to respond_to(:other=)
  end
end
