require 'spec_helper'

describe Mapper::Attribute, '#aliased_field' do
  subject { attribute.aliased_field(prefix, aliased) }

  let(:attribute) { subclass.new(:title) }
  let(:prefix)    { :book }

  context "when the name should be aliased" do
    let(:aliased) { true }

    its(:name) { should be(:book_title) }
  end

  context "when the name should not be aliased" do
    let(:aliased) { false }

    its(:name) { should be(:title) }
  end
end
