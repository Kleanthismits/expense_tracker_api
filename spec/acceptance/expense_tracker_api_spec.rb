require 'rack/test'
require 'json'
require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API', :db do
    include Rack::Test::Methods

    it 'records submitted expenses' do
      pending 'Need to persist expenses'

      coffee = post_expense(
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2021-10-20'
      )

      zoo = post_expense(
        'payee' => 'Zoo Foods',
        'amount' => 15.25,
        'date' => '2021-10-20'
      )

      groceries = post_expense(
        'payee' => 'Whole Foods',
        'amount' => 95.2,
        'date' => '21-10-2021'
      )

      get 'expenses/2021-10-20'

      expect(last_response.status).to eq 200

      expenses = JSON.parse(last_response.body)

      expect(expenses).to contain_exactly(coffee, zoo)
    end

    private

    def app
      ExpenseTracker::Api.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)

      expect(last_response.status).to eq 200

      parsed = JSON.parse last_response.body

      expect(parsed).to include('expense_id' => a_kind_of(Integer))

      expense.merge(id: parsed['expense_id'])
    end

  end
end
