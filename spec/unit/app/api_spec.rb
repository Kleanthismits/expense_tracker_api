require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  Expense = Struct.new(:payee, :amount, :date)

  RSpec.describe Api do
    include Rack::Test::Methods

    def app
      Api.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'GET/expenses' do
      context 'when expenses exist' do
        before do
          allow(ledger).to receive(:expenses)
            .and_return(
              [
                Expense.new('Starbucks', 5.75, '2021-10-20'),
                Expense.new('Zoo', 15.25, '2021-10-20'),
                Expense.new('Super Market', 45.70, '2021-10-21')
              ]
            )
        end
        it 'returns the expense records as JSON' do
          get '/expenses'
          parsed = JSON.parse(last_response.body)

          expect(parsed.size).to eq(3)
        end

        it 'returns status 200(OK)' do
          get '/expenses'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when no expenses exist' do
        before do
          allow(ledger).to receive(:expenses)
            .and_return([])
        end


        it 'returns an empty array as JSON' do
          get '/expenses'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to be_empty
        end

        it 'returns status 200(OK)' do
          get '/expenses'
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe 'GET/expenses/:date' do
      context 'when expenses exist in the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2021-10-20')
            .and_return(
              [
                Expense.new('Starbucks', 5.75, '2021-10-20'),
                Expense.new('Zoo', 15.25, '2021-10-20'),
              ]
            )
        end
        let(:date) { '2021-10-20' }

        it 'returns the expense records as JSON' do
          get '/expenses/2021-10-20'
          parsed = JSON.parse(last_response.body)

          expect(parsed.size).to eq(2)
        end
        it 'returns status 200(OK)' do
          get '/expenses/2021-10-20'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when no expenses exist in the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2021-10-20')
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          get '/expenses/2021-10-20'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to be_empty
        end

        it 'returns status 200(OK)' do
          get '/expenses/2021-10-20'
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe 'POST/expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with a 200(OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense Incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense Incomplete')
        end

        it 'responds with a 422' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
