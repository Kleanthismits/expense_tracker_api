require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def record(expense)
      error = validate_expense(expense)
      return error unless error.nil?

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    def expenses
      DB[:expenses].all
    end

    private

    def validate_expense(expense)
      return error_result('Invalid expense: `payee` is required') unless expense.key?('payee')
      return error_result('`Amount` should be a number') unless expense['amount'].is_a? Numeric
    end

    def error_result(message)
      RecordResult.new(false, nil, message)
    end
  end
end
