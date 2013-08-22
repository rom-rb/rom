# encoding: utf-8

require 'spec_helper'

describe Session::Relation, '#new' do
  share_examples_for 'a new tracked object' do
    it { should be_instance_of(model) }

    it 'sets state to transient' do
      expect(object.state(subject)).to be_transient
    end

    it 'auto-tracks the new object' do
      expect(object.tracking?(subject)).to be_true
    end
  end

  include_context 'Session::Relation'

  let(:attributes) { Hash[:id => 1, :name => 'Jane'] }

  context 'with attributes' do
    subject { users.new(attributes) }

    it { should eq(model.new(attributes)) }

    it_behaves_like 'a new tracked object'
  end

  context 'with attributes and block' do
    subject { users.new(attributes, &block) }

    let(:model) {
      Class.new {
        attr_reader :attributes

        def initialize(attributes, &block)
          @attributes = attributes
          yield(attributes)
        end
      }
    }

    let(:block) { proc { |attributes| attributes[:test] = true } }

    its(:attributes) { should eq(attributes.merge(:test => true)) }

    it_behaves_like 'a new tracked object'
  end
end
