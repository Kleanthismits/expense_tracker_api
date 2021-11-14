require 'sinatra/base'
require 'json'
require_relative 'ledger'

module ExpenseTracker
  class Api < Sinatra::Base

    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = ledger.record(expense)

      return JSON.generate('expense_id' => result.expense_id) if result.success?

      status 422
      JSON.generate('error' => result.error_message)
    end

    get '/expenses' do
      result = ledger.expenses
      JSON.generate(result)
    end

    get '/expenses/:date' do
      result = ledger.expenses_on(params[:date])
      JSON.generate(result)
    end

    private

    attr_reader :ledger
  end
end
