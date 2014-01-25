# encoding: utf-8

require 'spec_helper'

describe Relation, '#wrap' do
  include_context 'City with location'

  subject { relation.wrap(location: [:lat, :lng]).to_a }

  it { should eql([city]) }
end
