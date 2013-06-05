require 'spec_helper'

describe ROM::Session::State, '#identity' do
  subject { object.identity }
  
  let(:object)        { described_class.new(mapper, domain_object)             }
  let(:mapper)        { mock('Mapper', :dumper => dumper)                      }
  let(:domain_object) { mock('Domain Object')                                  }
  let(:dumper)        { mock('Dumper', :identity => identity, :tuple => tuple) }
  let(:identity)      { mock('Identity')                                       }
  let(:tuple)         { mock('Tuple')                                          }

  it { should be(identity) }

  it_should_behave_like 'an idempotent method'
end

