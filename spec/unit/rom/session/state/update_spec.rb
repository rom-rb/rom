require 'spec_helper'

describe ROM::Session::State, '#update' do
  subject { object.update(old_state) }

  let(:object)        { described_class.new(mapper, domain_object)              }
  let(:mapper)        { mock('Mapper', :dumper => dumper)                       }
  let(:dumper)        { mock('Dumper', :tuple  => tuple, :identity => identity) }
  let(:identity)      { mock('Identity')                                        }
  let(:tuple)         { mock('Tuple')                                           }
  let(:domain_object) { mock('Domain Object')                                   }
  let(:old_state)     { mock('Old State', :tuple => old_tuple)                  }

  context 'when tuple equals old tuple' do
    let(:old_tuple) { tuple }
    it_should_behave_like 'a command method'
  end

  context 'when tuple not equals old tuple' do
    let(:old_tuple) { mock('Old Tuple') }

    let(:operand) do
      ROM::Session::Operand::Update.new(ROM::Session::State.new(mapper, domain_object), old_tuple)
    end

    before do
      mapper.should_receive(:update).with(operand)
    end

    it_should_behave_like 'a command method'
  end
end
