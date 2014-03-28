# encoding: utf-8

require 'spec_helper'

describe Relation, '#wrap' do
  include_context 'City with location'

  subject { relation.wrap(location: location_relation).to_a }

  before { pending }

  it { should eql([city]) }
end
