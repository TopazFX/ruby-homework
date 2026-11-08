# frozen_string_literal: true

require 'set'

module Battleship
  # Корабель: список клітинок і множина влучань
  class Ship
    attr_reader :cells

    def initialize(cells)
      @cells = cells
      @hits = Set.new
    end

    def size
      @cells.size
    end

    def occupies?(cell)
      @cells.include?(cell)
    end

    def register_hit(cell)
      @hits << cell if occupies?(cell)
    end

    def sunk?
      @hits.size == size
    end
  end
end
