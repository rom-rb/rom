require 'spec_helper'

describe DataMapper::Mapper, '#load' do
  subject { mapper.load({}) }

  let(:mapper) { described_class.new }

  specify do
    pending
  end
end
