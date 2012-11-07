require 'spec_helper'

describe RelationRegistry::Builder, '#initialize' do
  subject { described_class.new(relations, mappers, relationship) }

  let(:relations)    { mock('RelationRegistry') }
  let(:mappers)      { mock('MapperRegistry')   }
  let(:relationship) { mock('Relationship')     }

  # TODO find a way to reuse "it_should_behave_like 'an abstract class'
  specify { expect { subject }.to raise_error(NotImplementedError, "#{described_class} is an abstract class") }
end
