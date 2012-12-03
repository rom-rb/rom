require 'spec_helper'
require 'data_mapper/engine/arel'

describe Engine::Arel::Engine, "#initialize" do
  subject { described_class.new(uri, engine_class) }

  let(:engine_class) { mock('engine_class') }
  let(:uri)          { "#{adapter}://#{username}:#{password}@#{host}/#{db}" }
  let(:adapter)      { "postgresql" }
  let(:username)     { "root" }
  let(:password)     { "secret" }
  let(:host)         { "localhost" }
  let(:db)           { "foobar" }

  before do
    engine_class.should_receive(:establish_connection).
      with(:adapter => adapter, :database => db, :username => username, :password => password)
  end

  its(:arel_engines) { should eql({}) }
end
