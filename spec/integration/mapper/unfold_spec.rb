# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mapper definition DSL' do
  include_context 'container'

  before do
    configuration.relation(:users)

    users = configuration.default.dataset(:users)

    users.insert(name: 'Joe',  roles: ['admin', 'user', 'user', nil])
    users.insert(name: 'Jane', roles: 'user')
    users.insert(name: 'John')
  end

  describe 'unfold' do
    let(:mapped_users) { container.relations[:users].map_with(:users).to_a }

    it 'splits the attribute' do
      configuration.mappers do
        define(:users) { unfold :roles }
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  roles: 'admin' },
        { name: 'Joe',  roles: 'user'  },
        { name: 'Joe',  roles: 'user'  },
        { name: 'Joe',  roles: nil     },
        { name: 'Jane', roles: 'user'  },
        { name: 'John'                 }
      ]
    end

    it 'renames unfolded attribute when necessary' do
      configuration.mappers do
        define(:users) { unfold :role, from: :roles }
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  role: 'admin' },
        { name: 'Joe',  role: 'user'  },
        { name: 'Joe',  role: 'user'  },
        { name: 'Joe',  role: nil     },
        { name: 'Jane', role: 'user'  },
        { name: 'John'                }
      ]
    end

    it 'rewrites the existing attribute' do
      configuration.mappers do
        define(:users) { unfold :name, from: :roles }
      end

      expect(mapped_users).to eql [
        { name: 'admin' },
        { name: 'user'  },
        { name: 'user'  },
        { name: nil     },
        { name: 'user'  },
        {}
      ]
    end

    it 'ignores the absent attribute' do
      configuration.mappers do
        define(:users) { unfold :foo, from: :absent }
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  roles: ['admin', 'user', 'user', nil] },
        { name: 'Jane', roles: 'user' },
        { name: 'John' }
      ]
    end

    it 'accepts block' do
      configuration.mappers do
        define(:users) { unfold(:role, from: :roles) {} }
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  role: 'admin' },
        { name: 'Joe',  role: 'user'  },
        { name: 'Joe',  role: 'user'  },
        { name: 'Joe',  role: nil     },
        { name: 'Jane', role: 'user'  },
        { name: 'John'                }
      ]
    end
  end
end
