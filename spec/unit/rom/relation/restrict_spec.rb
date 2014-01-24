# encoding: utf-8

require 'spec_helper'

describe Relation, '#restrict' do
  include_context 'Relation'

  share_examples_for 'restricted relation' do
    specify do
      should eq([jane])
    end
  end

  context 'with condition hash' do
    subject { relation.restrict(name: 'Jane').to_a }

    it_behaves_like 'restricted relation'
  end

  context 'with a block' do
    subject { relation.restrict { |r| r.name.eq('Jane') }.to_a }

    it_behaves_like 'restricted relation'
  end
end
