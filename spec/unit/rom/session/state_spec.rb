require 'spec_helper'

describe Session::State do
  fake(:object)
  fake(:mapper)
  fake(:relation)

  describe '#transient?' do
    context 'with transient state' do
      subject { Session::State::Transient.new(object, mapper) }

      it { should be_transient }
    end

    context 'with a non-transient state' do
      subject { Session::State::Persisted.new(object, mapper) }

      it { should_not be_transient }
    end
  end

  describe '#persisted?' do
    context 'with a persisted state' do
      subject { Session::State::Persisted.new(object, mapper) }

      it { should be_persisted }
    end

    context 'with a non-persisted state' do
      subject { Session::State::Transient.new(object, mapper) }

      it { should_not be_persisted }
    end
  end

  describe '#created?' do
    context 'with a created state' do
      subject { Session::State::Created.new(object, mapper, relation) }

      it { should be_created }
    end

    context 'with a non-created state' do
      subject { Session::State::Transient.new(object, mapper) }

      it { should_not be_created }
    end
  end

  describe '#updated?' do
    context 'with an updated state' do
      subject { Session::State::Updated.new(object, [], relation) }

      it { should be_updated }
    end

    context 'with a non-updated state' do
      subject { Session::State::Transient.new(object, mapper) }

      it { should_not be_updated }
    end
  end

  describe '#deleted?' do
    context 'with a deleted state' do
      subject { Session::State::Deleted.new(object, relation) }

      it { should be_deleted }
    end

    context 'with a non-updated state' do
      subject { Session::State::Transient.new(object, mapper) }

      it { should_not be_deleted }
    end
  end
end
