# encoding: utf-8

require 'spec_helper'

describe Relation, '#sort_by' do
  include_context 'Relation'

  share_examples_for 'sorted relation' do
    specify do
      should eql([jack, jade, jane, john])
    end
  end

  context 'with a list of attribute names' do
    subject { relation.sort_by([:name]).to_a }

    it_behaves_like 'sorted relation'
  end

  context 'with a block' do
    subject { relation.sort_by { |r| [r.name] }.to_a }

    it_behaves_like 'sorted relation'
  end
end
