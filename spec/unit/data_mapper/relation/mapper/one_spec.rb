require 'spec_helper'

describe Relation::Mapper, '#one' do
  let(:object)   { mock_mapper(model, [ id, name ]).new(ROM_ENV, node) }
  let(:id)       { mock_attribute(:id, Integer) }
  let(:name)     { mock_attribute(:name, String) }
  let(:node)     { Relation::Graph::Node.new(:users, relation) }
  let(:relation) { mock_relation('users', header, tuples) }
  let(:header)   { [ [ :id, Integer ], [ :name, String ] ] }
  let(:model)    { mock_model(:User) }

  let(:limit) { described_class::DEFAULT_LIMIT_FOR_ONE }

  let(:limited_relation) {
    relation.restrict(conditions).sort_by(relation.header).take(limit)
  }

  before do
    object.should_receive(:limited_relation).with(conditions, limit).and_return(limited_relation)
  end

  context "when conditions are given" do
    subject { object.one(conditions) }

    let(:tuples) { [ [ 1, 'John' ], [ 2, 'John' ] ] }

    context "when zero results are returned" do
      let(:conditions) { { :name => 'Jane' } }

      specify do
        expect { subject }.to raise_error(NoTuplesError, 'one tuple expected, but none was returned')
      end
    end

    context "when 1 result is returned" do
      let(:conditions) { { :id => 1 } }

      its(:id)   { should == 1 }
      its(:name) { should == 'John' }
    end

    context "when more than 1 result is returned" do
      let(:conditions) { { :name => 'John' } }

      specify do
        expect { subject }.to raise_error(ManyTuplesError, 'one tuple expected, but 2 were returned')
      end
    end
  end

  context "when no conditions are given" do
    subject { object.one }

    let(:conditions) { {} }

    context "when zero results are returned" do
      let(:tuples) { [] }

      specify do
        expect { subject }.to raise_error(NoTuplesError, 'one tuple expected, but none was returned')
      end
    end

    context "when 1 result is returned" do
      let(:tuples) { [ [ 1, 'John' ] ] }

      its(:id)   { should == 1 }
      its(:name) { should == 'John' }
    end

    context "when more than 1 result is returned" do
      let(:tuples) { [ [ 1, 'John' ], [ 2, 'Jane' ] ] }

      specify do
        expect { subject }.to raise_error(ManyTuplesError, 'one tuple expected, but 2 were returned')
      end
    end
  end
end
