require 'spec_helper'

describe DataMapper::Mapper::Attribute::EmbeddedCollection, '#load' do
  subject { attribute.load(tuple) }

  let(:attribute)      { described_class.new(:books, :type => model, :collection => true) }
  let(:mapper)         { mock('mapper') }
  let(:model)          { mock_model(:TestModel) }
  let(:tuple)          { { :books => [ book_tuple_one, book_tuple_two ] } }
  let(:book_tuple_one) { mock('book_tuple_one') }
  let(:book_tuple_two) { mock('book_tuple_two') }
  let(:book_one)       { mock('book_one') }
  let(:book_two)       { mock('book_two') }

  before do
    attribute.finalize(model => mapper)
    mapper.should_receive(:load).with(book_tuple_one).and_return(book_one)
    mapper.should_receive(:load).with(book_tuple_two).and_return(book_two)
  end

  it { should eql([ book_one, book_two ]) }
end
