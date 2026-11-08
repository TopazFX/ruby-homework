# frozen_string_literal: true

require_relative 'game'
require_relative 'statistics'

module Battleship
  # Головне меню програми
  class Menu
    RULES = <<~TEXT

      ПРАВИЛА
      - Поле 10×10: стовпці A-J, рядки 1-10.
      - Флот: 1 корабель на 4 клітинки, 2 на 3, 3 на 2, 4 на 1.
      - Кораблі не торкаються один одного, навіть по діагоналі.
      - Ходи робляться по черзі; влучання або знищення дає ще один постріл.
      - Виграє той, хто першим знищить усі кораблі суперника.
      - Координати вводяться як A1, b7, J10. Вихід з партії: q.
    TEXT

    def initialize(stats_path)
      @stats = Statistics.new(stats_path)
    end

    def run
      loop do
        show_menu
        print 'Ваш вибір > '
        choice = $stdin.gets
        if choice.nil?
          puts "\nДо побачення!"
          break
        end

        case choice.strip
        when '1' then Game.new(@stats).play
        when '2' then puts RULES
        when '3'
          puts 'До побачення!'
          break
        else puts 'Невідомий пункт меню. Введіть 1, 2 або 3.'
        end
      end
    end

    private

    def show_menu
      puts "\n===== МОРСЬКИЙ БІЙ ====="
      puts @stats
      puts '1. Нова гра'
      puts '2. Правила'
      puts '3. Вихід'
    end
  end
end
