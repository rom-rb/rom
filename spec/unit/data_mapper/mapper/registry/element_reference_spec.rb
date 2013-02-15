require 'spec_helper'

describe Mapper::Registry, '#[]', :type => :unit do
  let(:object) { described_class.new     }

  context "without a relationship" do
    subject { object[model] }

    let(:model)    { mock_model('TestModel') }
    let(:relation) { mock('relation') }
    let(:mapper)   { mock_mapper(model).new(DM_ENV, relation)  }

    before { object << mapper }

    it { should be(mapper) }
  end

  context "with a relationship" do
    subject { object[source_model, relationship] }

    let(:source_model) { mock_model('TestModel') }
    let(:target_model) { mock_model('Thing') }
    let(:relation)     { mock('relation') }
    let(:relationship) { mock_relationship(:things, :source_model => source_model, :target_model => target_model) }
    let(:mapper)       { mock_mapper(source_model).new(DM_ENV, relation)  }

    before { object.register mapper, relationship }

    it { should be(mapper) }
  end
end
