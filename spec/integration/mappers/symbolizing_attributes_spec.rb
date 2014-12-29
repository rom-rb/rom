require 'spec_helper'

describe 'Mappers / Symbolizing atributes' do
  let(:setup) { ROM.setup(memory: 'memory://test') }

  before do
    setup.schema do
      base_relation(:users) do
        repository :memory

        attribute 'user_id'
        attribute 'first_name'
        attribute 'email'
      end

      base_relation(:tasks) do
        repository :memory

        attribute 'title'
      end
    end
  end

  it 'automatically maps all attributes using top-level settings' do
    setup.mappers do
      define(:users, symbolize_keys: true, prefix: 'user') do
        model name: 'User'

        attribute :id

        wrap :details, prefix: 'first' do
          attribute :name
        end

        wrap :contact, prefix: false do
          attribute :email
        end
      end

      define(:tasks, symbolize_keys: true) do
        attribute :title
      end
    end

    rom = setup.finalize

    User.send(:include, Equalizer.new(:id, :details, :contact))

    rom.schema.users << {
      'user_id' => 123,
      'user_name' => 'Jane',
      'user_email' => 'jane@doe.org'
    }

    jane = rom.read(:users).first

    expect(jane).to eql(
      User.new(
        id: 123, details: { name: 'Jane' }, contact: { email: 'jane@doe.org' }
      )
    )

    rom.schema.tasks << { 'title' => 'Task One' }

    task = rom.read(:tasks).first

    expect(task).to eql({ title: 'Task One' })
  end
end
