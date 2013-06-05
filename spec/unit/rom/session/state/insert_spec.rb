require 'spec_helper'

describe ROM::Session::State, '#insert' do
  subject { object.insert }

  let(:object)        { described_class.new(mapper, domain_object)              }
  let(:mapper)        { mock('Mapper', :dumper => dumper)                       }
  let(:dumper)        { mock('Dumper', :tuple  => tuple, :identity => identity) }
  let(:identity)      { mock('Identity')                                        }
  let(:tuple)         { mock('Tuple')                                           }
  let(:domain_object) { mock('Domain Object')                                   }

  let(:operand) do
    ROM::Session::Operand.new(ROM::Session::State.new(mapper, domain_object))
  end

  before do
    mapper.should_receive(:insert).with(operand)
  end

  it_should_behave_like 'a command method'
end
