require 'spec_helper'

describe Mapper::Attribute, '#aliased_field' do
  subject { attribute.aliased_field(prefix) }

  let(:attribute) { described_class.new(:title) }
  let(:prefix)    { :book }

  it { should be(:book_title) }
end
