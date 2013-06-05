require 'spec_helper'

describe ROM::Session::Operand, '#object' do
  subject { object.object }

  let(:object) { described_class.new(state) }

  let(:identity)      { mock('Identity')      }
  let(:domain_object) { mock('Domain Object') }
  let(:tuple)         { mock('Tuple')         }

  let(:state) do
    mock('State',
      :tuple    => tuple,
      :object   => domain_object,
      :identity => identity
    )
  end

  it { should be(domain_object) }

  it_should_behave_like 'an idempotent method'
end
