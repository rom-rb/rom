require 'spec_helper'

describe DataMapper, '.engines' do
  subject { DataMapper.engines }

  it { should be_instance_of(Hash) }
end
