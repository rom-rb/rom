require 'spec_helper'

describe DataMapper::Mapper, '#dump' do
  subject { mapper.dump({}) }

  let(:mapper) { described_class.new }

  specify do
    pending
  end
end
