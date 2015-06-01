require 'spec_helper'
require 'rom/memory'

describe 'Mapper definition DSL' do
  let(:setup) { ROM.setup(:memory) }
  let(:rom)   { ROM.finalize.env   }

  before do
    setup.relation(:users)

    users = setup.default.dataset(:users)
    users.insert(name: 'Joe', emails: [
      { address: 'joe@home.org', type: 'home' },
      { address: 'joe@job.com',  type: 'job'  },
      { address: 'joe@doe.com',  type: 'job'  },
      { address: 'joe@thor.org'               },
      {                          type: 'home' },
      {}
    ])
    users.insert(name: 'Jane')
  end

  describe 'ungroup' do
    subject(:mapped_users) { rom.relation(:users).as(:users).to_a }

    it 'partially ungroups attributes' do
      setup.mappers do
        define(:users) { ungroup emails: [:type] }
      end

      expect(mapped_users).to eql [
        {
          name: 'Joe', type: 'home',
          emails: [{ address: 'joe@home.org' }, { address: nil }]
        },
        {
          name: 'Joe', type: 'job',
          emails: [{ address: 'joe@job.com' }, { address: 'joe@doe.com' }]
        },
        {
          name: 'Joe', type: nil,
          emails: [{ address: 'joe@thor.org' }, { address: nil }]
        },
        { name: 'Jane' }
      ]
    end

    it 'removes group when all attributes extracted' do
      setup.mappers do
        define(:users) { ungroup emails: [:address, :type, :foo] }
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  address: 'joe@home.org', type: 'home' },
        { name: 'Joe',  address: 'joe@job.com',  type: 'job'  },
        { name: 'Joe',  address: 'joe@doe.com',  type: 'job'  },
        { name: 'Joe',  address: 'joe@thor.org', type: nil    },
        { name: 'Joe',  address: nil,            type: 'home' },
        { name: 'Joe',  address: nil,            type: nil    },
        { name: 'Jane'                                        }
      ]
    end

    it 'accepts block syntax' do
      setup.mappers do
        define(:users) do
          ungroup :emails do
            attribute :address
            attribute :type
          end
        end
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  address: 'joe@home.org', type: 'home' },
        { name: 'Joe',  address: 'joe@job.com',  type: 'job'  },
        { name: 'Joe',  address: 'joe@doe.com',  type: 'job'  },
        { name: 'Joe',  address: 'joe@thor.org', type: nil    },
        { name: 'Joe',  address: nil,            type: 'home' },
        { name: 'Joe',  address: nil,            type: nil    },
        { name: 'Jane'                                        }
      ]
    end

    it 'renames ungrouped attributes' do
      setup.mappers do
        define(:users) do
          ungroup :emails do
            attribute :email, from: :address
            attribute :type
          end
        end
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  email: 'joe@home.org', type: 'home' },
        { name: 'Joe',  email: 'joe@job.com',  type: 'job'  },
        { name: 'Joe',  email: 'joe@doe.com',  type: 'job'  },
        { name: 'Joe',  email: 'joe@thor.org', type: nil    },
        { name: 'Joe',  email: nil,            type: 'home' },
        { name: 'Joe',  email: nil,            type: nil    },
        { name: 'Jane'                                      }
      ]
    end

    it 'skips existing attributes' do
      setup.mappers do
        define(:users) do
          ungroup :emails do
            attribute :name, from: :address
            attribute :type
          end
        end
      end

      expect(mapped_users).to eql [
        { name: 'Joe',  type: 'home' },
        { name: 'Joe',  type: 'job'  },
        { name: 'Joe',  type: 'job'  },
        { name: 'Joe',  type: nil    },
        { name: 'Joe',  type: 'home' },
        { name: 'Joe',  type: nil    },
        { name: 'Jane'               }
      ]
    end
  end
end
