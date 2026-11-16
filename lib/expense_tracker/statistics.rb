# frozen_string_literal: true

require_relative 'expense'

module ExpenseTracker
  # Підрахунки за списком витрат
  class Statistics
    def initialize(expenses)
      @expenses = expenses
    end

    def total
      sum(@expenses)
    end

    # Усі категорії, навіть нульові
    def by_category
      Expense::CATEGORIES.to_h do |category|
        [category, sum(@expenses.select { |e| e.category == category })]
      end
    end

    # Усі витрати з максимальною сумою
    def largest
      return [] if @expenses.empty?

      max = @expenses.map(&:amount_in_kopecks).max
      @expenses.select { |e| e.amount_in_kopecks == max }
    end

    private

    def sum(list)
      list.sum(&:amount_in_kopecks)
    end
  end
end
