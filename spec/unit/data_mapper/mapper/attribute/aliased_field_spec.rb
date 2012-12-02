require 'spec_helper'

describe Mapper::Attribute, '#aliased_field' do
  subject { attribute.aliased_field(prefix) }

  let(:attribute) { subclass.new(:title) }
  let(:prefix)    { :book }

  its(:name) { should be(:book_title) }
end
