# frozen_string_literal: true

require_relative 'errors'
require_relative 'expense'
require_relative 'record_parser'

module ExpenseTracker
  # Імпорт витрат із JSON-файла. Це "все або нічого": якщо є хоч один
  # некоректний запис, не імпортується жодного.
  module Importer
    # first_id — перший вільний id; нові записи отримують first_id, first_id+1, ...
    def self.load(path, first_id)
      raise ImportError, 'Шлях до файла не вказано.' if path.to_s.strip.empty?
      raise ImportError, "Файл «#{path}» не знайдено." unless File.exist?(path)
      raise ImportError, "«#{path}» не є звичайним файлом." unless File.file?(path)

      text = File.read(path, encoding: 'UTF-8')
      source = "Файл імпорту «#{path}»"
      records = RecordParser.parse_array(text, ImportError, source)
      RecordParser.build(records, ImportError, source) do |record, index|
        Expense.from_h(record, id: first_id + index)
      end
    rescue SystemCallError, IOError => e
      raise ImportError, "Не вдалося прочитати файл «#{path}»: #{e.message}"
    end
  end
end
