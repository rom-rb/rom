require 'spec_helper'

describe DataMapper::Mapper, '#dump' do
  subject { object.dump(user) }

  let(:object) { mapper.new }

  let(:mapper) { Class.new(described_class) { map :name, String, :to => :username } }
  let(:user)   { model.new(:name => name) }
  let(:model)  { mock_model('User') }
  let(:name)   { 'Piotr' }

  before { mapper.model(model) }

  it { should be_instance_of(Hash) }

  it { should eql({ :username => name }) }
end
