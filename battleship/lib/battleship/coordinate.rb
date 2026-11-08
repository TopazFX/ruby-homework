# frozen_string_literal: true

module Battleship
  # Перетворення тексту ("B7") у координати [рядок, стовпець] і навпаки
  module Coordinate
    LETTERS = %w[A B C D E F G H I J].freeze
    PATTERN = /\A([A-J])\s*(10|[1-9])\z/i

    def self.parse(input)
      match = PATTERN.match(input.to_s.strip)
      raise InvalidCoordinateError, input.to_s.strip unless match

      [match[2].to_i - 1, LETTERS.index(match[1].upcase)]
    end

    def self.label(cell)
      "#{LETTERS[cell[1]]}#{cell[0] + 1}"
    end
  end
end
