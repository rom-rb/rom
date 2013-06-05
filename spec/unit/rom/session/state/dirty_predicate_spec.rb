require 'spec_helper'

describe ROM::Session::State, '#dirty?' do
  subject { object.dirty?(old_state) }

  let(:object)        { described_class.new(mapper, domain_object)              }
  let(:mapper)        { mock('Mapper', :dumper => dumper)                       }
  let(:dumper)        { mock('Dumper', :tuple  => tuple, :identity => identity) }
  let(:identity)      { mock('Identity')                                        }
  let(:tuple)         { mock('Tuple')                                           }
  let(:domain_object) { mock('Domain Object')                                   }
  let(:old_state)     { mock('Old State', :tuple => old_tuple)                  }

  context 'when tuple equals old tuple' do
    let(:old_tuple) { tuple }
  
    it { should be(false) }

    it_should_behave_like 'an idempotent method'
  end

  context 'when tuple not equals old tuple' do
    let(:old_tuple) { mock('Old Tuple') }
  
    it { should be(true) }

    it_should_behave_like 'an idempotent method'
  end
end

