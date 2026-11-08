# frozen_string_literal: true

# Запуск: ruby main.rb
require_relative 'lib/battleship/menu'

begin
  Battleship::Menu.new(File.join(__dir__, 'stats.json')).run
rescue Interrupt
  puts "\nПрограму завершено користувачем."
end
