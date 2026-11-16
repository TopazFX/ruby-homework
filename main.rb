# frozen_string_literal: true

# Запуск: ruby main.rb [шлях_до_файла_даних]
require_relative 'lib/expense_tracker/cli'

data_path = ARGV[0] || File.join(__dir__, 'expenses.json')

begin
  storage = ExpenseTracker::Storage.new(data_path)
  book = ExpenseTracker::ExpenseBook.open(storage)
rescue ExpenseTracker::DataFileError => e
  warn "Помилка запуску: #{e.message}"
  warn 'Файл не було змінено. Виправте його або вкажіть інший шлях: ruby main.rb <файл>'
  exit 1
end

begin
  ExpenseTracker::CLI.new(book).run
rescue Interrupt
  puts "\nПрограму завершено користувачем (збережені зміни не втрачено)."
end
