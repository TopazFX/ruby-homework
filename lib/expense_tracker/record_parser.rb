# frozen_string_literal: true

require 'json'
require_relative 'errors'

module ExpenseTracker
  # Спільна логіка читання JSON-масиву записів (файл даних та файл імпорту)
  module RecordParser
    MAX_REPORTED = 10

    # Текст -> масив елементів. Будь-яка проблема -> error_class з поясненням.
    def self.parse_array(text, error_class, source)
      raise error_class, "#{source} містить некоректний UTF-8." unless text.valid_encoding?

      text = text.sub(/\A\uFEFF/, '') # BOM, який додає Блокнот Windows
      raise error_class, "#{source} порожній." if text.strip.empty?

      data = JSON.parse(text)
      raise error_class, "#{source}: очікується JSON-масив записів." unless data.is_a?(Array)

      data
    rescue JSON::ParserError => e
      reason = e.message.lines.first.to_s.strip[0, 120]
      raise error_class, "#{source} не є коректним JSON (#{reason})."
    end

    # Будує об'єкти Expense. Блок отримує (запис, індекс). Якщо є хоч одна помилка —
    # піднімається error_class із переліком проблем, нічого не повертається.
    def self.build(records, error_class, source)
      errors = []
      built = []
      records.each_with_index do |record, index|
        built << yield(record, index)
      rescue ValidationError => e
        errors << "запис №#{index + 1}: #{e.message}"
      end
      return built if errors.empty?

      lines = errors.first(MAX_REPORTED).map { |line| "  - #{line}" }
      lines << "  ... та ще помилок: #{errors.size - MAX_REPORTED}" if errors.size > MAX_REPORTED
      raise error_class, "#{source} містить некоректні записи (#{errors.size}):\n#{lines.join("\n")}"
    end
  end
end
