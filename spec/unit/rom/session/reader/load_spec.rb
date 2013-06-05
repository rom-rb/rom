require 'spec_helper'

describe ROM::Session::Reader, '#load' do
  subject { object.load(tuple) }

  let(:object) { described_class.new(session, mapper) }

  let(:session)       { mock('Session', :load => domain_object) }
  let(:mapper)        { mock('Mapper', :loader => loader)       }
  let(:domain_object) { mock('Domain Object')                   }
  let(:loader)        { mock('Loader')                          }

  let(:tuple) { mock('Tuple') }

  # Fixme:
  #   I do not like this message expectations on mocked objects 
  #   Need to specify behavior and not implementation 
  it 'should user loader from calling Mapper#loader(tuple)' do
    mapper.should_receive(:loader).with(tuple).and_return(loader)
    subject
  end

  it 'should return domain object from calling Session#load(loader)' do
    session.should_receive(:load).with(loader).and_return(domain_object)
    subject
  end

  it { should be(domain_object) }
end
