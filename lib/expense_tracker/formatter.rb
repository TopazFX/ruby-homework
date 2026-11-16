# frozen_string_literal: true

module ExpenseTracker
  # Форматування грошей і таблиць
  module Formatter
    HEADERS = ['ID', 'Дата', 'Категорія', 'Сума, грн', 'Опис'].freeze
    ALIGN = %i[right left left right left].freeze

    # 12550 -> "125.50"
    def self.money(kopecks)
      format('%d.%02d', kopecks / 100, kopecks % 100)
    end

    def self.table(expenses)
      rows = expenses.map do |e|
        [e.id.to_s, e.date.to_s, e.category, money(e.amount_in_kopecks),
         e.description.gsub(/\s+/, ' ')]
      end
      widths = HEADERS.each_index.map do |i|
        ([HEADERS[i]] + rows.map { |r| r[i] }).map(&:length).max
      end

      render = lambda do |cells|
        cells.each_with_index.map do |cell, i|
          ALIGN[i] == :right ? cell.rjust(widths[i]) : cell.ljust(widths[i])
        end.join(' | ')
      end

      separator = widths.map { |w| '-' * w }.join('-+-')
      [render.call(HEADERS), separator, *rows.map { |r| render.call(r) }].join("\n")
    end
  end
end
