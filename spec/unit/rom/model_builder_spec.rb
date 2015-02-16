require 'spec_helper'

describe ROM::ModelBuilder do
  describe '#call' do
    it 'builds a class with a constructor accepting attributes' do
      builder = ROM::ModelBuilder::PORO.new

      klass = builder.call([:name])

      object = klass.new(name: 'Jane')

      expect(object.name).to eql('Jane')

      expect { object.name = 'Jane' }.to raise_error(NoMethodError)

      klass = builder.call([:name, :email])

      object = klass.new(name: 'Jane', email: 'jane@doe.org')

      expect(object.name).to eql('Jane')
      expect(object.email).to eql('jane@doe.org')
    end

    context 'when :name option is present' do
      it 'defines a constant for the model' do
        builder = ROM::ModelBuilder::PORO.new(name: 'User')

        builder.call([:name, :email])

        expect(Object.const_defined?(:User)).to be(true)
        Object.send(:remove_const, :User)
      end

      it 'defines a constant within a namespace for the model' do
        module Test::MyApp; module Entities; end; end

        builder = ROM::ModelBuilder::PORO.new(name: 'Test::MyApp::Entities::User')

        builder.call([:name, :email])

        expect(Test::MyApp::Entities.const_defined?(:User)).to be(true)
        expect(Object.const_defined?(:User)).to be(false)
      end
    end
  end
end
