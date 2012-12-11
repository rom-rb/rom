require 'spec_helper'

describe Engine, '.register_as' do
  let(:object) { Class.new(Engine) }

  after(:all) { Engine.engines.delete(:limbo) }

  it "registers engine class under given name" do
    object.register_as(:limbo)
    expect(described_class.engines).to include(:limbo => object)
  end
end
