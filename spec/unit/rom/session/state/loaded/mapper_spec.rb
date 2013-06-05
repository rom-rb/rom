require 'spec_helper'

describe ROM::Session::State::Loaded, '#mapper' do
  subject { object.mapper }

  let(:object) { described_class.new(loader) }
  let(:mapper)  { mock('Mapper') }
  let(:loader) do
    mock('Loader',
      :mapper => mapper
    )
  end

  it { should be(mapper) }

  it_should_behave_like 'an idempotent method'
end
