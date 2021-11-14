require_relative '../../../app/api'

module ExpenseTracker
  RSpec.describe Ledger, :aggregate_failures, :db do
    let(:ledger) { Ledger.new }
    let(:expense) do
      {
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2021-10-20'
      }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'successfully saves the expense in the DB' do
          result = ledger.record(expense)

          expect(result).to be_success
          expect(DB[:expenses].all).to match [a_hash_including(
            id: result.expense_id,
            payee: 'Starbucks',
            amount: 5.75,
            date: Date.iso8601('2021-10-20')
          )]
        end
      end

      context 'with an invalid expense rejects the expense' do
        it 'if the amount is not a number' do
          expense['amount'] = 'amount'

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to eq(nil)
          expect(result.error_message).to include('`Amount` should be a number')
        end

        it 'if it does not contain a `payee`' do
          expense.delete('payee')

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to eq(nil)
          expect(result.error_message).to include('`payee` is required')
        end
      end

    end

    describe '#expenses_on' do
      it 'returns all the expenses for the provided date' do
        result1 = ledger.record(expense.merge('date' => '2021-10-21'))
        result2 = ledger.record(expense.merge('date' => '2021-10-21'))
        ledger.record(expense.merge('date' => '2021-10-22'))

        expect(ledger.expenses_on('2021-10-21')).to contain_exactly(
          a_hash_including(id: result1.expense_id),
          a_hash_including(id: result2.expense_id)
        )
      end

      it 'returns an empty array when there are no matching expenses' do
        expect(ledger.expenses_on('2021-10-21')).to be_empty
      end
    end
  end
end
