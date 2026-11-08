# frozen_string_literal: true

require 'set'
require_relative 'board'

module Battleship
  # Суперник: випадкові постріли + добивання пораненого корабля.
  # Ніколи не стріляє двічі в одну клітинку.
  class ComputerAI
    def initialize
      @tried = Set.new
      @blocked = Set.new   # клітинки навколо потоплених кораблів (там кораблів бути не може)
      @current_hits = []
    end

    def next_shot
      candidates = target_candidates
      candidates = all_available if candidates.empty?
      candidates.sample
    end

    def register(cell, result)
      @tried << cell
      case result.status
      when :hit
        @current_hits << cell
      when :sunk
        @current_hits << cell
        @current_hits.each { |c| Board.surrounding(c).each { |n| @blocked << n } }
        @current_hits.clear
      end
    end

    private

    def available?(cell)
      Board.in_bounds?(cell) && !@tried.include?(cell) && !@blocked.include?(cell)
    end

    def all_available
      cells = (0...Board::SIZE).to_a.product((0...Board::SIZE).to_a).select { |c| available?(c) }
      # запасний варіант: якщо евристика заблокувала все, стріляємо в будь-яку нестріляну
      cells.empty? ? (0...Board::SIZE).to_a.product((0...Board::SIZE).to_a).reject { |c| @tried.include?(c) } : cells
    end

    def target_candidates
      return [] if @current_hits.empty?

      cells =
        if @current_hits.size == 1
          r, c = @current_hits.first
          [[r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1]]
        elsif @current_hits.map(&:first).uniq.size == 1 # горизонтально
          row = @current_hits.first.first
          cols = @current_hits.map(&:last)
          [[row, cols.min - 1], [row, cols.max + 1]]
        else # вертикально
          col = @current_hits.first.last
          rows = @current_hits.map(&:first)
          [[rows.min - 1, col], [rows.max + 1, col]]
        end
      cells.select { |c| available?(c) }
    end
  end
end
