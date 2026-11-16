# frozen_string_literal: true

require_relative 'errors'
require_relative 'expense'
require_relative 'storage'
require_relative 'importer'

module ExpenseTracker
  # Колекція витрат. Стан у пам'яті змінюється лише після успішного збереження,
  # тому при помилці запису дані в пам'яті залишаються попередніми.
  class ExpenseBook
    def self.open(storage)
      new(storage, storage.load)
    end

    def initialize(storage, expenses)
      @storage = storage
      @expenses = expenses
    end

    # Відсортовано за датою, а для однакових дат — за id
    def all
      @expenses.sort_by { |e| [e.date, e.id] }
    end

    def find(id)
      @expenses.find { |e| e.id == id } || raise(NotFoundError, "Витрату з id #{id} не знайдено.")
    end

    def add(date:, amount_in_kopecks:, category:, description:)
      expense = Expense.new(id: next_id, date: date, amount_in_kopecks: amount_in_kopecks,
                            category: category, description: description)
      persist(@expenses + [expense])
      expense
    end

    def delete(id)
      target = find(id)
      persist(@expenses.reject { |e| e.id == id })
      target
    end

    # Повертає кількість імпортованих записів
    def import_file(path)
      imported = Importer.load(path, next_id)
      return 0 if imported.empty?

      persist(@expenses + imported)
      imported.size
    end

    def filter(category: nil, from: nil, to: nil)
      if from && to && from > to
        raise ValidationError, 'Початкова дата періоду не може бути пізнішою за кінцеву.'
      end

      all.select do |e|
        (category.nil? || e.category == category) &&
          (from.nil? || e.date >= from) &&
          (to.nil? || e.date <= to)
      end
    end

    private

    def next_id
      (@expenses.map(&:id).max || 0) + 1
    end

    def persist(candidate)
      @storage.save(candidate)
      @expenses = candidate
    end
  end
end
