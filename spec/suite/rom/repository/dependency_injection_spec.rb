# frozen_string_literal: true

RSpec.describe "Repository with additional dependencies injected" do
  include_context "repository / db_uri"

  let(:configuration) {
    ROM::Setup.new(default: [:sql, db_uri], memory: [:memory])
  }

  let(:rom) { ROM.setup(configuration) }

  describe "keyword constructor params" do
    describe "direct injection in single subclass" do
      let(:repo_class) {
        Class.new(ROM::Repository) do
          attr_reader :my_dep

          def initialize(my_dep:, **args)
            @my_dep = my_dep
            super(**args)
          end
        end
      }

      it "supports additional dependencies" do
        my_dep = Object.new
        repo = repo_class.new(container: rom, my_dep: my_dep)

        expect(repo.container).to eql rom
        expect(repo.my_dep).to eql my_dep
      end
    end

    describe "injections across deeper class hierarchy" do
      before do
        Test.const_set(:ROM, rom)
      end

      let(:base_repo_class) {
        Class.new(ROM::Repository) do
          def self.new(**args)
            super(container: Test::ROM, **args)
          end
        end
      }

      let(:repo_class) {
        Class.new(base_repo_class) do
          attr_reader :my_dep

          def initialize(my_dep:, **args)
            @my_dep = my_dep
            super(**args)
          end
        end
      }

      it "supports additional dependencies provided from various classes in the hierarchy" do
        my_dep = Object.new
        repo = repo_class.new(my_dep: my_dep)

        expect(repo.container).to eql rom
        expect(repo.my_dep).to eql my_dep
      end
    end
  end

  describe "positional constructor param for container" do
    describe "direct injection in single subclass" do
      let(:repo_class) {
        Class.new(ROM::Repository) do
          attr_reader :my_dep

          def initialize(*args, my_dep:, **kwargs)
            @my_dep = my_dep
            super(*args, **kwargs)
          end
        end
      }

      it "supports additional dependencies" do
        my_dep = Object.new
        repo = repo_class.new(rom, my_dep: my_dep)

        expect(repo.container).to eql rom
        expect(repo.my_dep).to eql my_dep
      end
    end
  end
end
