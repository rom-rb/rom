require 'spec_helper'

# http://en.wikipedia.org/wiki/Monad_%28functional_programming%29#Monad_laws
describe 'Commands / Result Monad' do
  include_context 'users and tasks'

  before do
    setup.relation(:users)
    setup.commands(:users) { define(:create) }
  end

  subject(:users) { rom.commands.users }

  let(:on_success) { RecordCalls.new { |value, result| result.success(value) } }
  let(:on_failure) { RecordCalls.new { |error, result| result.failure(error) } }

  describe "Laws" do
    let(:success_fn) { ->(value, results) { results.success([value, value]) } }
    let(:failure_fn) { ->(value, results) { results.failure([value, value]) } }

    describe "associativity" do
      let(:run_chained) do
        users.
          try { users.create.call(name: "Bob") }.
          and_then(&success_fn).
          and_then(&on_success)
      end

      let(:run_nested) do
        users.
          try { users.create.call(name: "Bob") }.
          and_then { |value, results|
            success_fn.call(value, results).and_then(&on_success)
          }
      end

      before do
        run_chained
        run_nested
      end

      specify { expect(run_chained).to eq run_nested }
      specify { expect(on_success.call_count).to eq 2 }
      specify { expect(on_success.calls[0]).to eq on_success.calls[1] }
    end

    describe "identity" do
      let(:result) { ROM::Commands::Result }

      let(:value) { double(:value) }
      let(:error) { double(:error) }

      describe "left identity" do
        specify do
          a = result.success(value).and_then(&success_fn)
          b = success_fn.call(value, result)
          expect(a).to eq(b)
        end

        specify do
          a = result.failure(error).or_else(&failure_fn)
          b = failure_fn.call(error, result)
          expect(a).to eq(b)
        end
      end

      describe "right identity" do
        specify do
          b = result.success(value)
          # can't because of extra argument
          # a = b.and_then &result.public_method(:success)
          a = b.and_then { |value, r| r.success(value) }
          c = b.and_then { |value, _| result.success(value) }
          expect(a).to eq(b)
          expect(b).to eq(c)
        end

        specify do
          b = result.failure(error)
          # can't because of extra argument
          # a = b.or_else &result.public_method(:failure)
          a = b.or_else { |error, r| r.failure(error) }
          c = b.or_else { |error, _| result.failure(error) }
          expect(a).to eq(b)
          expect(b).to eq(c)
        end
      end
    end
  end
end
