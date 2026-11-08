# frozen_string_literal: true

require_relative 'errors'
require_relative 'coordinate'
require_relative 'ship'

module Battleship
  # Ігрове поле 10×10
  class Board
    SIZE = 10
    FLEET = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1].freeze
    ShotResult = Struct.new(:status, :ship) # status: :miss, :hit, :sunk

    attr_reader :ships

    def self.in_bounds?(cell)
      cell.all? { |v| v.between?(0, SIZE - 1) }
    end

    # Сама клітинка та всі 8 сусідів (включно з діагоналями)
    def self.surrounding(cell)
      (-1..1).flat_map { |dr| (-1..1).map { |dc| [cell[0] + dr, cell[1] + dc] } }
             .select { |c| in_bounds?(c) }
    end

    def initialize
      reset
    end

    def place_fleet!
      attempts = 0
      begin
        reset
        FLEET.each { |size| place_ship_randomly(size) }
      rescue PlacementError
        attempts += 1
        retry if attempts < 100
        raise
      end
    end

    def shoot(cell)
      raise InvalidCoordinateError unless Board.in_bounds?(cell)
      raise AlreadyShotError, Coordinate.label(cell) if @shots.key?(cell)

      ship = @ship_at[cell]
      if ship
        ship.register_hit(cell)
        @shots[cell] = :hit
        ShotResult.new(ship.sunk? ? :sunk : :hit, ship)
      else
        @shots[cell] = :miss
        ShotResult.new(:miss, nil)
      end
    end

    def all_sunk?
      @ships.all?(&:sunk?)
    end

    def ships_left
      @ships.count { |s| !s.sunk? }
    end

    # Рядки для відображення поля. reveal=true показує кораблі (власне поле)
    def render_lines(reveal:)
      lines = ['   ' + Coordinate::LETTERS.join(' ')]
      SIZE.times do |r|
        row = (0...SIZE).map { |c| symbol([r, c], reveal) }.join(' ')
        lines << format('%2d %s', r + 1, row)
      end
      lines
    end

    private

    def reset
      @ships = []
      @ship_at = {}
      @shots = {}
    end

    def symbol(cell, reveal)
      case @shots[cell]
      when :hit then 'X'
      when :miss then 'o'
      else reveal && @ship_at.key?(cell) ? '#' : '.'
      end
    end

    def place_ship_randomly(size)
      200.times do
        horizontal = rand < 0.5
        r = rand(SIZE)
        c = rand(SIZE)
        cells = Array.new(size) { |i| horizontal ? [r, c + i] : [r + i, c] }
        next unless can_place?(cells)

        ship = Ship.new(cells)
        @ships << ship
        cells.each { |cell| @ship_at[cell] = ship }
        return ship
      end
      raise PlacementError, "Не вдалося розмістити корабель довжиною #{size}"
    end

    def can_place?(cells)
      return false unless cells.all? { |c| Board.in_bounds?(c) }

      cells.none? { |cell| Board.surrounding(cell).any? { |n| @ship_at.key?(n) } }
    end
  end
end
