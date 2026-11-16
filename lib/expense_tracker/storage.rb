# frozen_string_literal: true

require 'json'
require_relative 'errors'
require_relative 'expense'
require_relative 'record_parser'

module ExpenseTracker
  # Збереження витрат у локальному JSON-файлі
  class Storage
    attr_reader :path

    def initialize(path)
      @path = path
    end

    # Файл відсутній -> []. Порожній/пошкоджений/некоректний -> DataFileError.
    # Файл ніколи не перезаписується під час завантаження.
    def load
      return [] unless File.exist?(@path)
      raise DataFileError, "#{@path} не є звичайним файлом." unless File.file?(@path)

      text = File.read(@path, encoding: 'UTF-8')
      source = "Файл даних «#{@path}»"
      records = RecordParser.parse_array(text, DataFileError, source)
      expenses = RecordParser.build(records, DataFileError, source) { |rec, _i| Expense.from_h(rec) }
      ensure_unique_ids(expenses)
      expenses
    rescue SystemCallError, IOError => e
      raise DataFileError, "Не вдалося прочитати файл «#{@path}»: #{e.message}"
    end

    # Запис через тимчасовий файл, щоб не пошкодити наявні дані при збої
    def save(expenses)
      data = expenses.sort_by(&:id).map(&:to_h)
      tmp = "#{@path}.tmp"
      File.write(tmp, "#{JSON.pretty_generate(data)}\n", encoding: 'UTF-8')
      File.rename(tmp, @path)
    rescue SystemCallError, IOError, EncodingError => e
      begin
        File.delete(tmp) if tmp && File.exist?(tmp)
      rescue SystemCallError
        nil
      end
      raise SaveError, "Не вдалося зберегти дані у «#{@path}»: #{e.message}"
    end

    private

    def ensure_unique_ids(expenses)
      duplicates = expenses.group_by(&:id).select { |_id, list| list.size > 1 }.keys
      return if duplicates.empty?

      raise DataFileError,
            "Файл даних «#{@path}» містить повторювані id: #{duplicates.sort.join(', ')}."
    end
  end
end
