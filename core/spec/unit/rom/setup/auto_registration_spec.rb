require 'rom/setup'
require 'rom/support/notifications'

RSpec.describe ROM::Setup, '#auto_registration' do
  let!(:loaded_features) { $LOADED_FEATURES.dup }

  subject(:setup) { ROM::Setup.new(notifications) }

  let(:notifications) { instance_double(ROM::Notifications::EventBus) }

  after do
    %i(Persistence Users CreateUser UserList My).each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end

    $LOADED_FEATURES.replace(loaded_features)
  end

  context 'with default component_dirs' do
    context 'with namespace turned on' do
      before do
        setup.auto_registration(SPEC_ROOT.join('fixtures/lib/persistence').to_s)
      end

      describe '#relations' do
        it 'loads files and returns constants' do
          expect(setup.relation_classes).to eql([Persistence::Relations::Users])
        end
      end

      describe '#commands' do
        it 'loads files and returns constants' do
          expect(setup.command_classes).to eql([Persistence::Commands::CreateUser])
        end
      end

      describe '#mappers' do
        it 'loads files and returns constants' do
          expect(setup.mapper_classes).to eql([Persistence::Mappers::UserList])
        end
      end
    end

    context 'with namespace turned off' do
      before do
        setup.auto_registration(SPEC_ROOT.join('fixtures/app'), namespace: false)
      end

      describe '#relations' do
        it 'loads files and returns constants' do
          expect(setup.relation_classes).to eql([Users])
        end
      end

      describe '#commands' do
        it 'loads files and returns constants' do
          expect(setup.command_classes).to eql([CreateUser])
        end
      end

      describe '#mappers' do
        it 'loads files and returns constants' do
          expect(setup.mapper_classes).to eql([UserList])
        end
      end
    end
  end

  context 'with custom component_dirs' do
    context 'with namespace turned on' do
      before do
        setup.auto_registration(
          SPEC_ROOT.join('fixtures/lib/persistence').to_s,
          component_dirs: {
            relations: :my_relations,
            mappers: :my_mappers,
            commands: :my_commands
          }
        )
      end

      describe '#relations' do
        it 'loads files and returns constants' do
          expect(setup.relation_classes).to eql([Persistence::MyRelations::Users])
        end
      end

      describe '#commands' do
        it 'loads files and returns constants' do
          expect(setup.command_classes).to eql([Persistence::MyCommands::CreateUser])
        end
      end

      describe '#mappers' do
        it 'loads files and returns constants' do
          expect(setup.mapper_classes).to eql([Persistence::MyMappers::UserList])
        end
      end
    end

    context 'with namespace turned off' do
      before do
        setup.auto_registration(
          SPEC_ROOT.join('fixtures/app'),
          component_dirs: {
            relations: :my_relations,
            mappers: :my_mappers,
            commands: :my_commands
          },
          namespace: false
        )
      end

      describe '#relations' do
        it 'loads files and returns constants' do
          expect(setup.relation_classes).to eql([Users])
        end
      end

      describe '#commands' do
        it 'loads files and returns constants' do
          expect(setup.command_classes).to eql([CreateUser])
        end
      end

      describe '#mappers' do
        it 'loads files and returns constants' do
          expect(setup.mapper_classes).to eql([UserList])
        end
      end
    end

    describe 'custom namespace' do
      context 'when namespace has subnamespace' do
         before do
          setup.auto_registration(
            SPEC_ROOT.join('fixtures/custom_namespace'),
            component_dirs: {
              relations: :relations,
              mappers: :mappers,
              commands: :commands
            },
            namespace: 'My::Namespace'
          )
        end

        describe '#relations' do
          it 'loads files and returns constants' do
            expect(setup.relation_classes).to eql([My::Namespace::Relations::Customers])
          end
        end

        describe '#commands' do
          it 'loads files and returns constants' do
            expect(setup.command_classes).to eql([My::Namespace::Commands::CreateCustomer])
          end
        end

        describe '#mappers' do
          it 'loads files and returns constants' do
            expect(setup.mapper_classes).to eql([My::Namespace::Mappers::CustomerList])
          end
        end

        context 'with possibly clashing namespace' do
          before do
            module My
              module Namespace
                module Customers
                end
              end
            end
          end

          it 'starts with the deepest constant' do
            expect(setup.relation_classes).to eql([My::Namespace::Relations::Customers])
          end
        end
      end

      context 'when namespace has wrong subnamespace' do
         subject(:registration) do
          setup.auto_registration(
            SPEC_ROOT.join('fixtures/wrong'),
            component_dirs: {
              relations: :relations,
              mappers: :mappers,
              commands: :commands
            },
            namespace: 'My::NewNamespace'
          )
        end

        describe '#relations' do
          specify { expect { registration }.to raise_exception NameError }
        end

        describe '#commands' do
          specify { expect { registration }.to raise_exception NameError }
        end

        describe '#mappers' do
          specify { expect { registration }.to raise_exception NameError }
        end
      end

      context 'when namespace does not implement subnamespace' do
        before do
          setup.auto_registration(
            SPEC_ROOT.join('fixtures/custom'),
            component_dirs: {
              relations: :relations,
              mappers: :mappers,
              commands: :commands
            },
            namespace: 'My::Namespace'
          )
        end

        describe '#relations' do
          it 'loads files and returns constants' do
            expect(setup.relation_classes).to eql([My::Namespace::Users])
          end
        end

        describe '#commands' do
          it 'loads files and returns constants' do
            expect(setup.command_classes).to eql([My::Namespace::CreateUser])
          end
        end

        describe '#mappers' do
          it 'loads files and returns constants' do
            expect(setup.mapper_classes).to eql([My::Namespace::UserList])
          end
        end
      end
    end
  end
end
