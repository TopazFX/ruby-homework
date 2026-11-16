# frozen_string_literal: true

require_relative 'errors'
require_relative 'expense'
require_relative 'expense_book'
require_relative 'statistics'
require_relative 'formatter'

module ExpenseTracker
  # Консольний інтерфейс
  class CLI
    CANCEL = ':q'
    YES = %w[y yes т так].freeze
    NO = %w[n no н ні].freeze

    class Cancelled < StandardError; end

    def initialize(book, input: $stdin, output: $stdout)
      @book = book
      @in = input
      @out = output
    end

    def run
      say "\n===== ExpenseTracker ====="
      loop do
        print_menu
        choice = ask('Ваш вибір: ')
        break if choice == '0'

        dispatch(choice)
      end
      say 'Роботу завершено. До побачення!'
    rescue InputClosed
      say "\nВвід закрито. Роботу завершено (усі успішні зміни вже збережено)."
    end

    private

    def dispatch(choice)
      case choice
      when '1' then safely { add_expense }
      when '2' then safely { list_expenses }
      when '3' then safely { filter_expenses }
      when '4' then safely { delete_expense }
      when '5' then statistics_menu
      when '6' then safely { import_expenses }
      else say "  ! Невідома команда «#{choice}». Оберіть пункт від 0 до 6."
      end
    end

    # Показує зрозуміле повідомлення і повертає до меню
    def safely
      yield
    rescue Cancelled
      say 'Дію скасовано.'
    rescue Error => e
      say "  ! #{e.message}"
    end

    # ---------- Меню ----------

    def print_menu
      say "\n1. Додати витрату"
      say '2. Переглянути всі витрати'
      say '3. Фільтрувати за категорією та періодом'
      say '4. Видалити витрату'
      say '5. Статистика'
      say '6. Імпорт із JSON-файла'
      say '0. Вихід'
    end

    # ---------- Дії ----------

    def add_expense
      say "Додавання витрати (введіть #{CANCEL}, щоб скасувати)."
      date = prompt('Дата (YYYY-MM-DD)') { |v| Expense.parse_date(v) }
      amount = prompt('Сума в копійках (напр. 12550 = 125.50 грн)') { |v| Expense.amount_from_text(v) }
      category = prompt("Категорія (#{Expense::CATEGORIES.join(', ')})") { |v| Expense.category_from_text(v) }
      description = prompt("Опис (1-#{Expense::MAX_DESCRIPTION_LENGTH} символів)") { |v| Expense.parse_description(v) }

      expense = @book.add(date: date, amount_in_kopecks: amount, category: category, description: description)
      say "Витрату додано (id #{expense.id}, #{Formatter.money(expense.amount_in_kopecks)} грн)."
    end

    def list_expenses
      expenses = @book.all
      if expenses.empty?
        say 'Список витрат порожній.'
        return
      end

      say Formatter.table(expenses)
      say "Усього записів: #{expenses.size}"
    end

    def filter_expenses
      say "Фільтрація (Enter — не обмежувати, #{CANCEL} — скасувати)."
      category = prompt_optional("Категорія (#{Expense::CATEGORIES.join(', ')})") { |v| Expense.category_from_text(v) }
      from, to, result = ask_period_and_filter(category)

      if result.empty?
        say "За вказаними умовами витрат не знайдено. Сума: #{Formatter.money(0)} грн."
      else
        say Formatter.table(result)
        say "Знайдено записів: #{result.size}. Сума: #{Formatter.money(result.sum(&:amount_in_kopecks))} грн."
      end
      [from, to]
    end

    # Питає дати, поки діапазон не стане коректним
    def ask_period_and_filter(category)
      loop do
        from = prompt_optional('Початкова дата (YYYY-MM-DD)') { |v| Expense.parse_date(v) }
        to = prompt_optional('Кінцева дата (YYYY-MM-DD)') { |v| Expense.parse_date(v) }
        begin
          return [from, to, @book.filter(category: category, from: from, to: to)]
        rescue ValidationError => e
          say "  ! #{e.message} Введіть дати ще раз."
        end
      end
    end

    def delete_expense
      id = prompt("Id витрати для видалення (#{CANCEL} — скасувати)") { |v| Expense.id_from_text(v) }
      expense = @book.find(id)
      say Formatter.table([expense])
      return say('Видалення скасовано.') unless confirm?('Видалити цю витрату?')

      @book.delete(id)
      say "Витрату з id #{id} видалено."
    end

    def import_expenses
      path = prompt("Шлях до JSON-файла (#{CANCEL} — скасувати)") do |v|
        raise ValidationError, 'Шлях не може бути порожнім.' if v.empty?

        v
      end
      path = File.expand_path(path.delete_prefix('"').delete_suffix('"'))
      count = @book.import_file(path)
      if count.zero?
        say 'Файл містить порожній список. Нічого не імпортовано.'
      else
        say "Імпортовано записів: #{count}."
      end
    end

    # ---------- Статистика ----------

    def statistics_menu
      loop do
        say "\n--- Статистика ---"
        say '1. Загальна статистика'
        say '2. Сума за період'
        say '0. Назад'
        case ask('Ваш вибір: ')
        when '1' then safely { overall_statistics }
        when '2' then safely { period_statistics }
        when '0' then return
        else say '  ! Невідома команда. Оберіть 0, 1 або 2.'
        end
      end
    end

    def overall_statistics
      expenses = @book.all
      if expenses.empty?
        say "Витрат ще немає. Загальна сума: #{Formatter.money(0)} грн."
        return
      end

      stats = Statistics.new(expenses)
      say "Загальна сума: #{Formatter.money(stats.total)} грн"
      say 'Суми за категоріями:'
      stats.by_category.each do |category, sum|
        say "  #{category.ljust(14)} #{Formatter.money(sum).rjust(12)} грн"
      end
      largest = stats.largest
      say "Найбільша витрата (#{Formatter.money(largest.first.amount_in_kopecks)} грн), записів: #{largest.size}"
      say Formatter.table(largest)
    end

    def period_statistics
      say "Сума за період (обидві дати включно, #{CANCEL} — скасувати)."
      result = nil
      loop do
        from = prompt('Початкова дата (YYYY-MM-DD)') { |v| Expense.parse_date(v) }
        to = prompt('Кінцева дата (YYYY-MM-DD)') { |v| Expense.parse_date(v) }
        begin
          result = @book.filter(from: from, to: to)
          break
        rescue ValidationError => e
          say "  ! #{e.message} Введіть дати ще раз."
        end
      end

      if result.empty?
        say "За цей період витрат немає. Сума: #{Formatter.money(0)} грн."
      else
        say Formatter.table(result)
        say "Сума за період: #{Formatter.money(result.sum(&:amount_in_kopecks))} грн (записів: #{result.size})."
      end
    end

    # ---------- Введення ----------

    def say(text = '')
      @out.puts(text)
    end

    def ask(prompt_text)
      @out.print(prompt_text)
      @out.flush
      line = @in.gets
      raise InputClosed if line.nil?

      line.encode(Encoding::UTF_8, invalid: :replace, undef: :replace).scrub('?').strip
    end

    # Питає значення, поки блок не прийме його без ValidationError
    def prompt(label)
      loop do
        value = ask("#{label}: ")
        raise Cancelled if value == CANCEL

        begin
          return yield(value)
        rescue ValidationError => e
          say "  ! #{e.message}"
        end
      end
    end

    # Те саме, але порожнє значення означає "пропустити" (nil)
    def prompt_optional(label)
      loop do
        value = ask("#{label} (Enter — пропустити): ")
        return nil if value.empty?
        raise Cancelled if value == CANCEL

        begin
          return yield(value)
        rescue ValidationError => e
          say "  ! #{e.message}"
        end
      end
    end

    def confirm?(question)
      loop do
        answer = ask("#{question} (y/n): ").downcase
        return true if YES.include?(answer)
        return false if NO.include?(answer)

        say '  ! Введіть y (так) або n (ні).'
      end
    end
  end
end
