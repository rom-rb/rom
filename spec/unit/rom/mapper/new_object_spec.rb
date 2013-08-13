require 'spec_helper'

describe Mapper, '#new_object' do
  subject { mapper.new_object(name: 'Jane', &block) }

  include_context 'Mapper'

  let(:attributes) { Hash[:id => 1, :name => 'Jane'] }
  let(:block)      { Proc.new { self.id = 1 } }

  it { should eql(model.new(attributes)) }
end
