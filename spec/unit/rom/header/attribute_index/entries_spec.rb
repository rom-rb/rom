require 'spec_helper'

describe Header::AttributeIndex, '#entries' do
  subject { described_class.new(entries, strategy_class) }

  let(:entries)        { { attribute_alias(:id, :users) => attribute_alias(:id, :users) } }
  let(:strategy_class) { Class.new }

  its(:entries) { should be(entries) }
end
