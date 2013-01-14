require 'spec_helper'

describe Relation::Aliases::AttributeIndex, '#entries' do
  subject { described_class.new(entries, strategy_class) }

  let(:entries)        { { attribute_alias(:id, :users) => attribute_alias(:id, :users) } }
  let(:strategy_class) { mock }

  its(:entries) { should be(entries) }
end
