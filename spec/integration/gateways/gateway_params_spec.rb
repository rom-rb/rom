# frozen_string_literal: true

RSpec.describe "Gateways / keyword arguments" do
  before do
    @adapter = Module.new
    class @adapter::Gateway < ROM::Gateway
      extend ROM::Initializer

      param :param
      option :option
    end
    ROM.register_adapter(:my_adapter, @adapter)
  end

  specify do
    gw = @adapter::Gateway.new(:param, option: :option)
    expect(gw.param).to eql(:param)
    expect(gw.option).to eql(:option)
  end

  specify do
    conf = ROM::Configuration.new(:my_adapter, :param, option: :option)
    container = ROM.container(conf)
    gw = container.gateways[:default]

    expect(gw.param).to eql(:param)
    expect(gw.option).to eql(:option)
  end
end
