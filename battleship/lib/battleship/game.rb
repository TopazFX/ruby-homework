# frozen_string_literal: true

require_relative 'errors'
require_relative 'board'
require_relative 'coordinate'
require_relative 'computer_ai'

module Battleship
  # Одна партія: гравець проти комп'ютера
  class Game
    def initialize(statistics)
      @stats = statistics
      @player_board = Board.new
      @computer_board = Board.new
      @ai = ComputerAI.new
    end

    def play
      @player_board.place_fleet!
      @computer_board.place_fleet!
      puts "\nГру розпочато! Кораблі розставлено автоматично."
      puts "Постріл: введіть координати (напр. B5). Для виходу з партії: q."

      winner = game_loop
      finish(winner)
    rescue PlacementError => e
      puts "Помилка розстановки: #{e.message}"
    end

    private

    # Влучання дає право на ще один постріл
    def game_loop
      loop do
        draw
        return :quit if (player_result = player_turn) == :quit

        return :player if @computer_board.all_sunk?
        next if %i[hit sunk].include?(player_result)

        loop do
          result = computer_turn
          return :computer if @player_board.all_sunk?
          break unless %i[hit sunk].include?(result)
        end
      end
    end

    def player_turn
      loop do
        print 'Ваш постріл > '
        line = $stdin.gets
        return :quit if line.nil? || line.strip.casecmp?('q')

        begin
          cell = Coordinate.parse(line)
          result = @computer_board.shoot(cell)
          report('Ви', cell, result)
          return result.status
        rescue GameError => e
          puts "  ! #{e.message}"
        end
      end
    end

    def computer_turn
      cell = @ai.next_shot
      result = @player_board.shoot(cell)
      @ai.register(cell, result)
      report('Комп\'ютер', cell, result)
      result.status
    rescue AlreadyShotError
      # Недосяжно за коректної роботи ШІ, але програма не має падати
      retry
    end

    def report(who, cell, result)
      label = Coordinate.label(cell)
      text =
        case result.status
        when :miss then 'промах.'
        when :hit then 'влучання!'
        when :sunk then "корабель знищено! (довжина: #{result.ship.size})"
        end
      puts "  #{who} стріляє в #{label}: #{text}"
    end

    def draw
      mine = @player_board.render_lines(reveal: true)
      enemy = @computer_board.render_lines(reveal: false)
      puts "\n  ВАШЕ ПОЛЕ (кораблів: #{@player_board.ships_left})        " \
           "ПОЛЕ СУПЕРНИКА (кораблів: #{@computer_board.ships_left})"
      mine.zip(enemy) { |a, b| puts "#{a.ljust(26)}#{b}" }
      puts "  Умовні позначки: # корабель, X влучання, o промах, . невідомо"
    end

    def finish(winner)
      case winner
      when :player
        draw
        puts "\n*** Вітаємо! Ви знищили всі кораблі суперника! ***"
        @stats.record_win
      when :computer
        draw
        puts "\n*** Комп'ютер переміг. Спробуйте ще раз! ***"
        @stats.record_loss
      when :quit
        puts "\nПартію перервано (зараховано як поразку)."
        @stats.record_loss
      end
    end
  end
end
